#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")

cd $THIS_DIR/bare-metal
./bare-metal_candle_benchmark_runner.sh

cd $THIS_DIR/VM
./VM_candle_benchmark_runner.sh

cd $THIS_DIR
./candle_benchmark_results.sh

mv results results_gramine_tdx_1_6_1

cd $THIS_DIR/bare-metal
./bare-metal_candle_benchmark_runner.sh

cd $THIS_DIR/VM
./VM_candle_benchmark_runner.sh

cd $THIS_DIR
./candle_benchmark_results.sh

mv results results_gramine_tdx_1_6_2

cd $THIS_DIR/bare-metal
./bare-metal_candle_benchmark_runner.sh

cd $THIS_DIR/VM
./VM_candle_benchmark_runner.sh

cd $THIS_DIR
./candle_benchmark_results.sh

mv results results_gramine_tdx_1_6_3
