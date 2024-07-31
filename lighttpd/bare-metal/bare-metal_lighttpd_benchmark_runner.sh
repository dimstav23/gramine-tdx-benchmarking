#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
DEPS_DIR=$THIS_DIR/../../common/bare-metal/deps
RESULTS_DIR=$THIS_DIR/../results
GRAMINE_SGX_INSTALL_DIR=$DEPS_DIR/gramine/build-release
GRAMINE_TDX_INSTALL_DIR=$DEPS_DIR/gramine-tdx/build-release
BENCHMARK_DIR=$DEPS_DIR/gramine/CI-Examples/lighttpd

THREADS=(1) # lighttpd is single threaded

BIND0="numactl --cpunodebind=0 --membind=0"
LIGHTTPD_INSTALL_DIR=$BENCHMARK_DIR/install
LIGHTTPD_PORT=8003
FWD_PORT=8004
CLIENT_BENCHMARK=$DEPS_DIR/gramine/CI-Examples/common_tools/benchmark-http.sh

pushd $BENCHMARK_DIR

#create temp directory for the results
mkdir -p results

function run_lighttpd() {
  echo "Running $1 lighttpd-server..."
  if [ "$1" = "native" ]; then
    # run the server manually in the native case
    $BIND0 $LIGHTTPD_INSTALL_DIR/sbin/lighttpd -D -m $LIGHTTPD_INSTALL_DIR/lib -f lighttpd.conf &
  else
    # run the server with the args configured in the manifest
    $BIND0 $1 lighttpd &
  fi
  
  if [ "$1" = "gramine-vm" ] || [ "$1" = "gramine-tdx" ]; then
    sleep 5
  else
    while ! lsof -i :$LIGHTTPD_PORT &> /dev/null; do
      sleep 1
    done
  fi
}

function run_socat() {
  echo "Running socat..."
  if [ "$1" = "TCP" ]; then
    $BIND0 socat TCP4-LISTEN:$FWD_PORT,reuseaddr,fork,backlog=256,nodelay TCP4-CONNECT:localhost:$LIGHTTPD_PORT &
  elif [ "$1" = "VSOCK" ]; then
    $BIND0 socat TCP4-LISTEN:$FWD_PORT,reuseaddr,fork,backlog=256,nodelay VSOCK-CONNECT:10:$LIGHTTPD_PORT &
    sleep 5
  fi
  while ! lsof -i :$FWD_PORT &> /dev/null; do
    sleep 1
  done
}

function run_benchmark() {
  echo "Running client benchmark..."
  DOWNLOAD_FILE=random/$4 $BIND0 $CLIENT_BENCHMARK http://127.0.0.1:$1 \
  | tail -n 6 | tee ./results/"$2"_"$3"_threads_$4.txt
}

function cleanup() {
  echo "Cleaning up..."
  kill $(jobs -p)
  while lsof -i :$LIGHTTPD_PORT &> /dev/null; do
    sleep 1
  done 
  while lsof -i :$FWD_PORT &> /dev/null; do
    sleep 1
  done 
}

# Run the native case
for THREAD_CNT in "${THREADS[@]}"; do
  run_lighttpd "native"
  run_benchmark $LIGHTTPD_PORT native $THREAD_CNT "100.1.html"
  run_benchmark $LIGHTTPD_PORT native $THREAD_CNT "10K.1.html"
  # run_benchmark $LIGHTTPD_PORT native $THREAD_CNT "1M.1.html"
  cleanup

  run_lighttpd "native"
  run_socat TCP
  run_benchmark $FWD_PORT socat-native $THREAD_CNT "100.1.html"
  run_benchmark $FWD_PORT socat-native $THREAD_CNT "10K.1.html"
  # run_benchmark $FWD_PORT socat-native $THREAD_CNT "1M.1.html"
  cleanup
done

# Preserve the current values of the env variables
CURR_PATH=$PATH
CURR_PYTHONPATH=$PYTHONPATH
CURR_PKG_CONFIG_PATH=$PKG_CONFIG_PATH

# Run the bare-metal (bm) gramine-direct and gramine-sgx case
export PATH=$GRAMINE_SGX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_SGX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_SGX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  run_lighttpd "gramine-sgx"
  run_benchmark $LIGHTTPD_PORT bm-gramine-sgx $THREAD_CNT "100.1.html"
  run_benchmark $LIGHTTPD_PORT bm-gramine-sgx $THREAD_CNT "10K.1.html"
  # run_benchmark $LIGHTTPD_PORT bm-gramine-sgx $THREAD_CNT "1M.1.html"
  cleanup

  # run_lighttpd "gramine-sgx"
  # run_socat TCP
  # run_benchmark $FWD_PORT bm-socat-gramine-sgx $THREAD_CNT "100.1.html"
  # run_benchmark $FWD_PORT bm-socat-gramine-sgx $THREAD_CNT "10K.1.html"
  # # run_benchmark $FWD_PORT bm-socat-gramine-sgx $THREAD_CNT "1M.1.html"
  # cleanup
done

# Run the gramine-vm and gramine-tdx case
export PATH=$GRAMINE_TDX_INSTALL_DIR/bin:$CURR_PATH
export PYTHONPATH=$GRAMINE_TDX_INSTALL_DIR/lib/$(python3 -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages:$CURR_PYTHONPATH
export PKG_CONFIG_PATH=$GRAMINE_TDX_INSTALL_DIR/lib/x86_64-linux-gnu/pkgconfig:$CURR_PKG_CONFIG_PATH
make clean && make SGX=1
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  run_lighttpd "gramine-vm"
  sleep 10
  run_socat VSOCK
  sleep 5
  run_benchmark $FWD_PORT gramine-vm $THREAD_CNT "100.1.html"
  run_benchmark $FWD_PORT gramine-vm $THREAD_CNT "10K.1.html"
  # run_benchmark $FWD_PORT gramine-vm $THREAD_CNT "1M.1.html"
  cleanup
  sleep 30
done
for THREAD_CNT in "${THREADS[@]}"; do
  export QEMU_CPU_NUM=$THREAD_CNT
  run_lighttpd "gramine-tdx"
  sleep 10
  run_socat VSOCK
  sleep 5
  run_benchmark $FWD_PORT gramine-tdx $THREAD_CNT "100.1.html"
  run_benchmark $FWD_PORT gramine-tdx $THREAD_CNT "10K.1.html"
  # run_benchmark $FWD_PORT gramine-tdx $THREAD_CNT "1M.1.html"
  cleanup
  sleep 30
done

mkdir -p $RESULTS_DIR
mv results/* $RESULTS_DIR
rm -rf results

popd
