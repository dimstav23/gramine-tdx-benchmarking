#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/examples/bild

THREADS=(1 2 4 8 16 32)

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

# make might require gramine binaries, so just export the paths
CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean
make SGX=1

# Run the native case
for THREAD_CNT in "${THREADS[@]}"; do
  # Manual go-bild execution, get the last 2 lines for the results with the metrics (tokens/s)
  GOMAXPROCS=$THREAD_CNT numactl --cpunodebind=0 --membind=0 ./bild_bench 2>&1 \
  | tail -n 3 | tee ./results/native_"$THREAD_CNT"_threads.txt
done

# Run the bare-metal (bm) gramine-sgx case
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean
make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  GOMAXPROCS=$THREAD_CNT numactl --cpunodebind=0 --membind=0 gramine-sgx bild_bench 2>&1 \
  | tail -n 3 | tee ./results/bm-gramine-sgx_"$THREAD_CNT"_threads.txt
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean
make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  GOMAXPROCS=$THREAD_CNT numactl --cpunodebind=0 --membind=0 gramine-vm bild_bench 2>&1 \
  | tail -n 3 | tee ./results/gramine-vm_"$THREAD_CNT"_threads.txt
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  GOMAXPROCS=$THREAD_CNT numactl --cpunodebind=0 --membind=0 gramine-tdx bild_bench 2>&1 \
  | tail -n 3 | tee ./results/gramine-tdx_"$THREAD_CNT"_threads.txt
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
