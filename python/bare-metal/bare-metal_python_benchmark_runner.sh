#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/gramine/CI-Examples/python

THREADS=(1 2 4 8 16 32)

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# Run the native case
for THREAD_CNT in "${THREADS[@]}"; do
  export OMP_NUM_THREADS=$THREAD_CNT
  export OPENBLAS_NUM_THREADS=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 python scripts/test-numpy.py \
  | tail -n 2 | tee ./results/numpy_native_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 python scripts/test-scipy.py \
  | tail -n 4 | tee ./results/scipy_native_"$THREAD_CNT"_threads.txt
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
  export OMP_NUM_THREADS=$THREAD_CNT
  export OPENBLAS_NUM_THREADS=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 gramine-sgx python scripts/test-numpy.py \
  | tail -n 2 | tee ./results/numpy_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-sgx python scripts/test-scipy.py \
  | tail -n 4 | tee ./results/scipy_bm-gramine-sgx_"$THREAD_CNT"_threads.txt
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  export OMP_NUM_THREADS=$THREAD_CNT
  export OPENBLAS_NUM_THREADS=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 gramine-vm python scripts/test-numpy.py \
  | tail -n 2 | tee ./results/numpy_gramine-vm_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-vm python scripts/test-scipy.py \
  | tail -n 4 | tee ./results/scipy_gramine-vm_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  export OMP_NUM_THREADS=$THREAD_CNT
  export OPENBLAS_NUM_THREADS=$THREAD_CNT
  numactl --cpunodebind=0 --membind=0 gramine-tdx python scripts/test-numpy.py \
  | tail -n 2 | tee ./results/numpy_gramine-tdx_"$THREAD_CNT"_threads.txt
  numactl --cpunodebind=0 --membind=0 gramine-tdx python scripts/test-scipy.py \
  | tail -n 4 | tee ./results/scipy_gramine-tdx_"$THREAD_CNT"_threads.txt
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
