#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/examples/tensorflow

THREADS=(1 2 4 8 16 32)

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# Run the native case
make clean
for THREAD_CNT in "${THREADS[@]}"; do
  OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  numactl --cpunodebind=0 --membind=0 \
  taskset -a -c 0-$((THREAD_CNT-1)) \
  python3 \
  models/models/language_modeling/tensorflow/bert_large/inference/run_squad.py \
  --init_checkpoint=data/bert_large_checkpoints/model.ckpt-3649 \
  --vocab_file=data/wwm_uncased_L-24_H-1024_A-16/vocab.txt \
  --bert_config_file=data/wwm_uncased_L-24_H-1024_A-16/bert_config.json \
  --predict_file=data/wwm_uncased_L-24_H-1024_A-16/dev-v1.1.json \
  --precision=int8 --output_dir=output/bert-squad-output \
  --predict_batch_size=32 \
  --experimental_gelu=True \
  --optimized_softmax=True \
  --input_graph=data/fp32_bert_squad.pb \
  --do_predict=True \
  --mode=benchmark \
  --inter_op_parallelism_threads=1 \
  --intra_op_parallelism_threads=$THREAD_CNT \
  | tail -n 4 | tee ./results/Bert_native_"$THREAD_CNT"_threads.txt
  
  # OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  # numactl --cpunodebind=0 --membind=0 \
  # taskset -a -c 0-$((THREAD_CNT-1)) \
  # python3 \
  # models/models/image_recognition/tensorflow/resnet50v1_5/inference/cpu/eval_image_classifier_inference.py \
  # --input-graph=data/resnet50v1_5_int8_pretrained_model.pb \
  # --num-inter-threads=1 \
  # --num-intra-threads=$THREAD_CNT \
  # --batch-size=512 \
  # --warmup-steps=50 \
  # --steps=500 \
  # | tail -n 4 | tee ./results/RN50_native_"$THREAD_CNT"_threads.txt
done

# Preserve the current values of the env variables
CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

# Run the bare-metal (bm) gramine-sgx case
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  numactl --cpunodebind=0 --membind=0 \
  taskset -a -c 0-$((THREAD_CNT-1)) \
  gramine-sgx python \
  models/models/language_modeling/tensorflow/bert_large/inference/run_squad.py \
  --init_checkpoint=data/bert_large_checkpoints/model.ckpt-3649 \
  --vocab_file=data/wwm_uncased_L-24_H-1024_A-16/vocab.txt \
  --bert_config_file=data/wwm_uncased_L-24_H-1024_A-16/bert_config.json \
  --predict_file=data/wwm_uncased_L-24_H-1024_A-16/dev-v1.1.json \
  --precision=int8 --output_dir=output/bert-squad-output \
  --predict_batch_size=32 \
  --experimental_gelu=True \
  --optimized_softmax=True \
  --input_graph=data/fp32_bert_squad.pb \
  --do_predict=True \
  --mode=benchmark \
  --inter_op_parallelism_threads=1 \
  --intra_op_parallelism_threads=$THREAD_CNT \
  | tail -n 4 | tee ./results/Bert_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
  
  # OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  # numactl --cpunodebind=0 --membind=0 \
  # taskset -a -c 0-$((THREAD_CNT-1)) \
  # gramine-sgx python \
  # models/models/image_recognition/tensorflow/resnet50v1_5/inference/cpu/eval_image_classifier_inference.py \
  # --input-graph=data/resnet50v1_5_int8_pretrained_model.pb \
  # --num-inter-threads=1 \
  # --num-intra-threads=$THREAD_CNT \
  # --batch-size=512 \
  # --warmup-steps=50 \
  # --steps=500 \
  # | tail -n 4 | tee ./results/RN50_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  echo "Running gramine-vm with $THREAD_CNT Thread(s)"
  export QEMU_CPU_NUM=$THREAD_CNT
  
  OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  numactl --cpunodebind=0 --membind=0 \
  taskset -a -c 0-$((THREAD_CNT-1)) \
  gramine-vm python \
  models/models/language_modeling/tensorflow/bert_large/inference/run_squad.py \
  --init_checkpoint=data/bert_large_checkpoints/model.ckpt-3649 \
  --vocab_file=data/wwm_uncased_L-24_H-1024_A-16/vocab.txt \
  --bert_config_file=data/wwm_uncased_L-24_H-1024_A-16/bert_config.json \
  --predict_file=data/wwm_uncased_L-24_H-1024_A-16/dev-v1.1.json \
  --precision=int8 --output_dir=output/bert-squad-output \
  --predict_batch_size=32 \
  --experimental_gelu=True \
  --optimized_softmax=True \
  --input_graph=data/fp32_bert_squad.pb \
  --do_predict=True \
  --mode=benchmark \
  --inter_op_parallelism_threads=1 \
  --intra_op_parallelism_threads=$THREAD_CNT \
  | tail -n 4 | tee ./results/Bert_gramine-vm_"$THREAD_CNT"_threads.txt

  # OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  # numactl --cpunodebind=0 --membind=0 \
  # taskset -a -c 0-$((THREAD_CNT-1)) \
  # gramine-vm python \
  # models/models/image_recognition/tensorflow/resnet50v1_5/inference/cpu/eval_image_classifier_inference.py \
  # --input-graph=data/resnet50v1_5_int8_pretrained_model.pb \
  # --num-inter-threads=1 \
  # --num-intra-threads=$THREAD_CNT \
  # --batch-size=512 \
  # --warmup-steps=50 \
  # --steps=500 \
  # | tail -n 4 | tee ./results/RN50_gramine-vm_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT

  OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  numactl --cpunodebind=0 --membind=0 \
  taskset -a -c 0-$((THREAD_CNT-1)) \
  gramine-tdx python \
  models/models/language_modeling/tensorflow/bert_large/inference/run_squad.py \
  --init_checkpoint=data/bert_large_checkpoints/model.ckpt-3649 \
  --vocab_file=data/wwm_uncased_L-24_H-1024_A-16/vocab.txt \
  --bert_config_file=data/wwm_uncased_L-24_H-1024_A-16/bert_config.json \
  --predict_file=data/wwm_uncased_L-24_H-1024_A-16/dev-v1.1.json \
  --precision=int8 --output_dir=output/bert-squad-output \
  --predict_batch_size=32 \
  --experimental_gelu=True \
  --optimized_softmax=True \
  --input_graph=data/fp32_bert_squad.pb \
  --do_predict=True \
  --mode=benchmark \
  --inter_op_parallelism_threads=1 \
  --intra_op_parallelism_threads=$THREAD_CNT \
  | tail -n 4 | tee ./results/Bert_gramine-tdx_"$THREAD_CNT"_threads.txt
  
  # OMP_NUM_THREADS=$THREAD_CNT KMP_AFFINITY=granularity=fine,verbose,compact,1,0 \
  # numactl --cpunodebind=0 --membind=0 \
  # taskset -a -c 0-$((THREAD_CNT-1)) \
  # gramine-tdx python \
  # models/models/image_recognition/tensorflow/resnet50v1_5/inference/cpu/eval_image_classifier_inference.py \
  # --input-graph=data/resnet50v1_5_int8_pretrained_model.pb \
  # --num-inter-threads=1 \
  # --num-intra-threads=$THREAD_CNT \
  # --batch-size=512 \
  # --warmup-steps=50 \
  # --steps=500 \
  # | tail -n 4 | tee ./results/RN50_gramine-tdx_"$THREAD_CNT"_threads.txt
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
