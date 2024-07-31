#!/usr/bin/bash

set -e

THIS_DIR=$(dirname "$(readlink -f "$0")")
GENERATOR_SCRIPT=$THIS_DIR/generate_plots.py

# bild
python3 -W ignore $GENERATOR_SCRIPT -d ../bild/results_gramine_tdx_1_6_1/ -a bild -e default -n absolute -m LIB -x threads -l "upper right" -t bild_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../bild/results_gramine_tdx_1_6_1/ -a bild -e default -n absolute -m LIB -x threads -l "upper right" -t bild
python3 -W ignore $GENERATOR_SCRIPT -d ../bild/results_gramine_tdx_1_6_1/ -a bild -e default -m LIB -x threads -l "upper right" -t bild_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../bild/results_gramine_tdx_1_6_1/ -a bild -e default -n absolute -m LIB -x threads -l "upper right" --error_bar -t bild_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../bild/results_gramine_tdx_1_6_1/ -a bild -e default -n overhead -m LIB -x threads -l "upper right" -t bild_overhead

# java_image
python3 -W ignore $GENERATOR_SCRIPT -d ../java_image/results_gramine_tdx_1_6_1/ -a java_image -e default -n absolute -m LIB -x threads -l "upper right" -t java_image_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../java_image/results_gramine_tdx_1_6_1/ -a java_image -e default -n absolute -m LIB -x threads -l "upper right" -t java_image
python3 -W ignore $GENERATOR_SCRIPT -d ../java_image/results_gramine_tdx_1_6_1/ -a java_image -e default -m LIB -x threads -l "upper right" -t java_image_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../java_image/results_gramine_tdx_1_6_1/ -a java_image -e default -n absolute -m LIB -x threads -l "upper right" --error_bar -t java_image_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../java_image/results_gramine_tdx_1_6_1/ -a java_image -e default -n overhead -m LIB -x threads -l "upper right" -t java_image_overhead

# candle
python3 -W ignore $GENERATOR_SCRIPT -d ../candle/results_gramine_tdx_1_6_1/ -a candle -e default -n absolute -m HIB -x threads -l "upper right" -t candle_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../candle/results_gramine_tdx_1_6_1/ -a candle -e default -n absolute -m HIB -x threads -l "upper right" -t candle
python3 -W ignore $GENERATOR_SCRIPT -d ../candle/results_gramine_tdx_1_6_1/ -a candle -e default -m HIB -x threads -l "upper right" -t candle_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../candle/results_gramine_tdx_1_6_1/ -a candle -e default -n absolute -m HIB -x threads -l "upper right" --error_bar -t candle_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../candle/results_gramine_tdx_1_6_1/ -a candle -e default -n overhead -m HIB -x threads -l "upper right" -t candle_overhead

# blender
python3 -W ignore $GENERATOR_SCRIPT -d ../blender/results_gramine_tdx_1_6_1/ -a blender -e default -n absolute -m LIB -x threads -l "upper right" -t blender_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../blender/results_gramine_tdx_1_6_1/:../blender/results_gramine_tdx_1_6_2/:../blender/results_gramine_tdx_1_6_3/ -a blender -e default -n absolute -m LIB -x threads -l "upper right" -t blender
python3 -W ignore $GENERATOR_SCRIPT -d ../blender/results_gramine_tdx_1_6_1/:../blender/results_gramine_tdx_1_6_2/:../blender/results_gramine_tdx_1_6_3/ -a blender -e default -m LIB -x threads -l "upper right" -t blender_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../blender/results_gramine_tdx_1_6_1/:../blender/results_gramine_tdx_1_6_2/:../blender/results_gramine_tdx_1_6_3/ -a blender -e default -n absolute -m LIB -x threads -l "upper right" --error_bar -t blender_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../blender/results_gramine_tdx_1_6_1/:../blender/results_gramine_tdx_1_6_2/:../blender/results_gramine_tdx_1_6_3/ -a blender -e default -n overhead -m LIB -x threads -l "upper right" -t blender_overhead

# lighttpd
python3 -W ignore $GENERATOR_SCRIPT -d ../lighttpd/results_gramine_tdx_1_6_1/ -a lighttpd -e 100,10K -n absolute -m HIB -x threads -l "upper left" -t lighttpd_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../lighttpd/results_gramine_tdx_1_6_1/:../lighttpd/results_gramine_tdx_1_6_2/:../lighttpd/results_gramine_tdx_1_6_3/ -a lighttpd -e 100,10K -n absolute -m HIB -x threads -l "upper left" -t lighttpd
python3 -W ignore $GENERATOR_SCRIPT -d ../lighttpd/results_gramine_tdx_1_6_1/:../lighttpd/results_gramine_tdx_1_6_2/:../lighttpd/results_gramine_tdx_1_6_3/ -a lighttpd -e 100,10K -m HIB -x threads -l "upper left" -t lighttpd_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../lighttpd/results_gramine_tdx_1_6_1/:../lighttpd/results_gramine_tdx_1_6_2/:../lighttpd/results_gramine_tdx_1_6_3/ -a lighttpd -e 100,10K -n absolute -m HIB -x threads -l "upper left" --error_bar -t lighttpd_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../lighttpd/results_gramine_tdx_1_6_1/:../lighttpd/results_gramine_tdx_1_6_2/:../lighttpd/results_gramine_tdx_1_6_3/ -a lighttpd -e 100,10K -n overhead -m HIB -x threads -l "upper left" -t lighttpd_overhead

# # python
# python3 -W ignore $GENERATOR_SCRIPT -d ../python/results_gramine_tdx_1_6_1/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -m LIB -x threads -l "upper right" -t python_single_res
# python3 -W ignore $GENERATOR_SCRIPT -d ../python/results_gramine_tdx_1_6_1/:../python/results_gramine_tdx_1_6_2/:../python/results_gramine_tdx_1_6_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -m LIB -x threads -l "upper right" -t python
# python3 -W ignore $GENERATOR_SCRIPT -d ../python/results_gramine_tdx_1_6_1/:../python/results_gramine_tdx_1_6_2/:../python/results_gramine_tdx_1_6_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -m LIB -x threads -l "upper right" -t python_no_annot
# python3 -W ignore $GENERATOR_SCRIPT -d ../python/results_gramine_tdx_1_6_1/:../python/results_gramine_tdx_1_6_2/:../python/results_gramine_tdx_1_6_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n absolute -m LIB -x threads -l "upper right" --error_bar -t python_error_bars
# python3 -W ignore $GENERATOR_SCRIPT -d ../python/results_gramine_tdx_1_6_1/:../python/results_gramine_tdx_1_6_2/:../python/results_gramine_tdx_1_6_3/ -a python -e numpy.dot,scipy.fft.fft2,scipy.linalg.svd -n overhead -m LIB -x threads -l "upper right" -t python_overhead

# pytorch
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/ -a pytorch -e default -n absolute -m LIB -x threads -l "upper right" -t pytorch_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ -a pytorch -e default -n absolute -m LIB -x threads -l "upper right" -t pytorch
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ -a pytorch -e default -m LIB -x threads -l "upper right" -t pytorch_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ -a pytorch -e default -n absolute -m LIB -x threads -l "upper right" --error_bar -t pytorch_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ -a pytorch -e default -n overhead -m LIB -x threads -l "upper right" -t pytorch_overhead

# openvino
python3 -W ignore $GENERATOR_SCRIPT -d ../openvino/results_gramine_tdx_1_6_1/ -a openvino -e RN50 -n absolute -m HIB -x threads -l "upper left" -t openvino_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ -a openvino -e RN50 -n absolute -m HIB -x threads -l "upper left" -t openvino
python3 -W ignore $GENERATOR_SCRIPT -d ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ -a openvino -e RN50 -m HIB -x threads -l "upper left" -t openvino_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ -a openvino -e RN50 -n absolute -m HIB -x threads -l "upper left" --error_bar -t openvino_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ -a openvino -e RN50 -n overhead -m HIB -x threads -l "upper left" -t openvino_overhead

# sqlite
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/ -a sqlite -e read,update,read-random,update-random -n absolute -m LIB -x experiments -l "upper left" -t sqlite_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ -a sqlite -e read,update,read-random,update-random -n absolute -m LIB -x experiments -l "upper left" -t sqlite
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ -a sqlite -e read,update,read-random,update-random -m LIB -x experiments -l "upper left" -t sqlite_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ -a sqlite -e read,update,read-random,update-random -n absolute -m LIB -x experiments -l "upper left" --error_bar -t sqlite_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ -a sqlite -e read,update,read-random,update-random -n overhead -m LIB -x experiments -l "upper left" -t sqlite_overhead

# sqlite-tmpfs
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_gramine_tdx_1_6_1/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -m LIB -x experiments -l "upper left" -t sqlite-tmpfs_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -m LIB -x experiments -l "upper left" -t sqlite-tmpfs
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -m LIB -x experiments -l "upper left" -t sqlite-tmpfs_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -n absolute -m LIB -x experiments -l "upper left" --error_bar -t sqlite-tmpfs_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ -a sqlite-tmpfs -e read,update,read-random,update-random -n overhead -m LIB -x experiments -l "upper left" -t sqlite-tmpfs_overhead

# tensorflow
python3 -W ignore $GENERATOR_SCRIPT -d ../tensorflow/results_gramine_tdx_1_6_1/ -a tensorflow -e Bert -n absolute -m HIB -x threads -l "upper left" -t tensorflow_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ -a tensorflow -e Bert -n absolute -m HIB -x threads -l "upper left" -t tensorflow
python3 -W ignore $GENERATOR_SCRIPT -d ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ -a tensorflow -e Bert -m HIB -x threads -l "upper left" -t tensorflow_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ -a tensorflow -e Bert -n absolute -m HIB -x threads -l "upper left" --error_bar -t tensorflow_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ -a tensorflow -e Bert -n overhead -m HIB -x threads -l "upper left" -t tensorflow_overhead

# redis - redis-benchmark
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/ -a redis  -e GET,SET,LRANGE-300 -n absolute -m HIB -x threads -l "upper center" -t redis_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -m HIB -x threads -l "upper center" -t redis
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -m HIB -x threads -l "upper center" -t redis_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -m HIB -x threads -l "upper center" --error_bar -t redis_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -n overhead -m HIB -x threads -l "upper center" -t redis_overhead
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/ -a redis  -e GET,SET,LRANGE-300 -n absolute -m HIB -x experiments -l "upper center" -t redis-experiments_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -m HIB -x experiments -l "upper center" -t redis-experiments
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -m HIB -x experiments -l "upper center" -t redis-experiments_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -n absolute -m HIB -x experiments -l "upper center" --error_bar -t redis-experiments_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e GET,SET,LRANGE-300 -n overhead -m HIB -x experiments -l "upper center" -t redis-experiments_overhead

# redis - memtier-benchmark
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/ -a redis  -e memtier-Get,memtier-Set -n absolute -m HIB -x threads -l "upper center" -t redis_memtier_single_res
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -n absolute -m HIB -x threads -l "upper center" -t redis_memtier
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -m HIB -x threads -l "upper center" -t redis_memtier_no_annot
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -n absolute -m HIB -x threads -l "upper center" --error_bar -t redis_memtier_error_bars
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -n overhead -m HIB -x threads -l "upper center" -t redis_memtier_overhead
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/ -a redis  -e memtier-Get,memtier-Set -n absolute -m HIB -x experiments -l "upper center" -t redis_memtier-experiments_single_res
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -n absolute -m HIB -x experiments -l "upper center" -t redis_memtier-experiments
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -m HIB -x experiments -l "upper center" -t redis_memtier-experiments_no_annot
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -n absolute -m HIB -x experiments -l "upper center" --error_bar -t redis_memtier-experiments_error_bars
# python3 -W ignore $GENERATOR_SCRIPT -d ../redis/results_gramine_tdx_1_6_1/:../redis/results_gramine_tdx_1_6_2/:../redis/results_gramine_tdx_1_6_3/ -a redis -e memtier-Get,memtier-Set -n overhead -m HIB -x experiments -l "upper center" -t redis_memtier-experiments_overhead

# memcached
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/ -a memcached -e TOTAL -n absolute -m HIB -x threads -l "upper left" -t memcached_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e TOTAL -n absolute -m HIB -x threads -l "upper left" -t memcached
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e TOTAL -m HIB -x threads -l "upper left" -t memcached_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e TOTAL -n absolute -m HIB -x threads -l "upper left" --error_bar -t memcached_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e TOTAL -n overhead -m HIB -x threads -l "upper left" -t memcached_overhead
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/ -a memcached  -e GET-4,SET-4 -n absolute -m HIB -x experiments -l "upper right" -t memcached-experiments_single_res
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e GET-4,SET-4 -n absolute -m HIB -x experiments -l "upper right" -t memcached-experiments
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e GET-4,SET-4 -m HIB -x experiments -l "upper right" -t memcached-experiments_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e GET-4,SET-4 -n absolute -m HIB -x experiments -l "upper right" --error_bar -t memcached-experiments_error_bars
python3 -W ignore $GENERATOR_SCRIPT -d ../memcached/results_gramine_tdx_1_6_1/:../memcached/results_gramine_tdx_1_6_2/:../memcached/results_gramine_tdx_1_6_3/ -a memcached -e GET-4,SET-4 -n overhead -m HIB -x experiments -l "upper right" -t memcached-experiments_overhead

# Combined plots

# Pytorch, Openvino (RN50), TF (Bert) -> 1 plot
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ \
  ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ \
  ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ \
  -a pytorch openvino tensorflow -e default RN50 Bert -n absolute -m LIB HIB HIB -x threads -l "upper right" -t AI_ML_frameworks
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ \
  ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ \
  ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ \
  -a pytorch openvino tensorflow -e default RN50 Bert -m LIB HIB HIB -x threads -l "upper right" -t AI_ML_frameworks_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../pytorch/results_gramine_tdx_1_6_1/:../pytorch/results_gramine_tdx_1_6_2/:../pytorch/results_gramine_tdx_1_6_3/ \
  ../openvino/results_gramine_tdx_1_6_1/:../openvino/results_gramine_tdx_1_6_2/:../openvino/results_gramine_tdx_1_6_3/ \
  ../tensorflow/results_gramine_tdx_1_6_1/:../tensorflow/results_gramine_tdx_1_6_2/:../tensorflow/results_gramine_tdx_1_6_3/ \
  -a pytorch openvino tensorflow -e default RN50 Bert -n absolute -m LIB HIB HIB -x threads -l "upper right" --error_bar -t AI_ML_frameworks_error_bars

# sqlite, sqlite-tmps -> 1 plot
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ \
  ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ \
  -a sqlite sqlite-tmpfs -e read,update,read-random,update-random read,update,read-random,update-random -n absolute -m LIB LIB -x experiments -l "upper left" -t sqlite_merged
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ \
  ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ \
  -a sqlite sqlite-tmpfs -e read,update,read-random,update-random read,update,read-random,update-random -m LIB LIB -x experiments -l "upper left" -t sqlite_merged_no_annot
python3 -W ignore $GENERATOR_SCRIPT -d ../sqlite/results_gramine_tdx_1_6_1/:../sqlite/results_gramine_tdx_1_6_2/:../sqlite/results_gramine_tdx_1_6_3/ \
  ../sqlite-tmpfs/results_gramine_tdx_1_6_1/:../sqlite-tmpfs/results_gramine_tdx_1_6_2/:../sqlite-tmpfs/results_gramine_tdx_1_6_3/ \
  -a sqlite sqlite-tmpfs -e read,update,read-random,update-random read,update,read-random,update-random -n absolute -m LIB LIB -x experiments -l "upper left" --error_bar -t sqlite_merged_error_bars

# # blender, lighttpd, memcached -> 1 plot
# python3 -W ignore $GENERATOR_SCRIPT -d ../blender/results_gramine_tdx_1_6_1/ ../lighttpd/results_gramine_tdx_1_6_1/ ../memcached/results_gramine_tdx_1_6_1/ \
#   -a blender lighttpd memcached -e default 10K default -n absolute -x threads -l "upper right" -t blender_lighttpd_memcached