#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/gramine/CI-Examples/memcached

THREADS=(1 2 4 8 16 32)

BIND0="numactl --cpunodebind=0 --membind=0"
BIND1="numactl --cpunodebind=1 --membind=1"

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

function run_memcached() {
  echo "Running $3 memcached at port "$1" with "$2" threads..."
  $BIND0 $3 ./memcached --port $1 --threads=$2 &
  if [ "$3" = "gramine-vm" ] || [ "$3" = "gramine-tdx" ]; then
    sleep 5
  else
    while ! lsof -i :$1 &> /dev/null; do
      sleep 1
    done
  fi
}

function run_socat() {
  echo "Running socat..."
  if [ "$1" = "TCP" ]; then
    $BIND0 socat TCP4-LISTEN:$2,reuseaddr,fork,backlog=256 TCP4-CONNECT:localhost:$3 &
  elif [ "$1" = "VSOCK" ]; then
    $BIND0 socat TCP4-LISTEN:$2,reuseaddr,fork,backlog=256 VSOCK-CONNECT:10:$3 &
    sleep 5
  fi
  while ! lsof -i :$2 &> /dev/null; do
    sleep 1
  done
}

function run_memtier() {
  echo "Running memtier..."
  $BIND0 memtier_benchmark --port=$1 --protocol=memcache_binary --hide-histogram \
  | tail -n 8 | tee ./results/"$2"_"$3"_threads.txt
}

function cleanup() {
  echo "Cleaning up..."
  kill $(jobs -p)
  while lsof -i :$1 &> /dev/null; do
    sleep 1
  done
  while lsof -i :$2 &> /dev/null; do
    sleep 1
  done
  
}

# Run the native case
for THREAD_CNT in "${THREADS[@]}"; do
  run_memcached 11211 $THREAD_CNT ""
  run_memtier 11211 native $THREAD_CNT
  cleanup 11211 11212

  run_memcached 11212 $THREAD_CNT ""
  run_socat TCP 11211 11212
  run_memtier 11211 socat-native $THREAD_CNT
  cleanup 11211 11212
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
  run_memcached 11211 $THREAD_CNT "gramine-sgx"
  run_memtier 11211 bm-gramine-sgx $THREAD_CNT
  cleanup 11211 11212

  # run_memcached 11212 $THREAD_CNT "gramine-sgx"
  # run_socat TCP 11211 11212
  # run_memtier 11211 bm-socat-gramine-sgx $THREAD_CNT
  # cleanup 11211 11212
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  run_memcached 11212 $THREAD_CNT "gramine-vm"
  sleep 10
  run_socat VSOCK 11211 11212
  sleep 5
  run_memtier 11211 gramine-vm $THREAD_CNT
  cleanup 11211 11212
  sleep 30
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  run_memcached 11212 $THREAD_CNT "gramine-tdx"
  sleep 10
  run_socat VSOCK 11211 11212
  sleep 5
  run_memtier 11211 gramine-tdx $THREAD_CNT
  cleanup 11211 11212
  sleep 30
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
