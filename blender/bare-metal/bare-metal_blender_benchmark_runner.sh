#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/gramine/CI-Examples/blender

THREADS=(1 2 4 8 16 32)

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# Run the native case
make clean
for THREAD_CNT in "${THREADS[@]}"; do
  # Manual blender execution
  rm -f ./data/images/simple_scene.blend0001.png
  export DATA_DIR=./data
  # Run the blender command, grep "Saving" (last line with the results) and place it into result file
  LD_LIBRARY_PATH=./blender_dir/lib/ numactl --cpunodebind=0 --membind=0 ./blender_dir/blender \
  -b ./data/scenes/simple_scene.blend -t $THREAD_CNT -F PNG -o ./data/images/simple_scene.blend -f 1 \
  | grep "Saving" | tee ./results/native_"$THREAD_CNT"_threads.txt
done

# Preserve the current values of the env variables
CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

# Run the bare-metal (bm) gramine-sgx case
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean
for THREAD_CNT in "${THREADS[@]}"; do
  numactl --cpunodebind=0 --membind=0 make check SGX=1 THREADS=$THREAD_CNT VARIANT=bm-gramine-sgx
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 make check THREADS=$THREAD_CNT VARIANT=gramine-vm
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 make check SGX=1 THREADS=$THREAD_CNT VARIANT=gramine-tdx
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
