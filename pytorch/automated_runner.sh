#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")

cd $THIS_DIR/bare-metal
./bare-metal_pytorch_benchmark_runner.sh

cd $THIS_DIR/VM
./VM_pytorch_benchmark_runner.sh

cd $THIS_DIR
./pytorch_benchmark_results.sh

mv results results_gramine_tdx_1_6_1

cd $THIS_DIR/bare-metal
./bare-metal_pytorch_benchmark_runner.sh

cd $THIS_DIR/VM
./VM_pytorch_benchmark_runner.sh

cd $THIS_DIR
./pytorch_benchmark_results.sh

mv results results_gramine_tdx_1_6_2

cd $THIS_DIR/bare-metal
./bare-metal_pytorch_benchmark_runner.sh

cd $THIS_DIR/VM
./VM_pytorch_benchmark_runner.sh

cd $THIS_DIR
./pytorch_benchmark_results.sh

mv results results_gramine_tdx_1_6_3