#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")

------ start of new apps
cd $THIS_DIR/bild
./automated_runner.sh

cd $THIS_DIR/java_image
./automated_runner.sh

cd $THIS_DIR/candle
./automated_runner.sh

cd $THIS_DIR/blender
./automated_runner.sh

cd $THIS_DIR/pytorch
./automated_runner.sh

# # cd $THIS_DIR/python
# # ./automated_runner.sh

cd $THIS_DIR/sqlite
./automated_runner.sh

cd $THIS_DIR/sqlite-tmpfs
./automated_runner.sh

cd $THIS_DIR/openvino
./automated_runner.sh

cd $THIS_DIR/lighttpd
./automated_runner.sh

cd $THIS_DIR/redis
./automated_runner.sh

cd $THIS_DIR/tensorflow
./automated_runner.sh

cd $THIS_DIR/memcached
./automated_runner.sh

# Generate the plots
cd $THIS_DIR/plots
./plot_generator.sh

# Run the microbenchmark
# cd $THIS_DIR/microbenchmarks/startup-time
# ./measure_gramine_startup_time.sh
# ./measure_VM_startup_time.expect
# python pretty_print_results.py
