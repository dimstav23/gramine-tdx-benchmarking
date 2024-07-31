#!/usr/bin/bash

apt update

#Install gramine dependencies
apt install build-essential autoconf bison gawk nasm numactl -y
apt install ninja-build pkg-config python3 python3-click -y
apt install python3-jinja2 python3-pip python3-pyelftools wget -y
apt install meson python3-tomli python3-tomli-w python3-voluptuous -y
apt install libprotobuf-c-dev protobuf-c-compiler protobuf-compiler -y
apt install python3-cryptography python3-pip python3-protobuf -y

#Fetch the git URLs and the stable-commits
. /root/stable-commits

#Build and install gramine
cd /root
git clone ${GRAMINE_GIT_URL}
cd /root/gramine
git checkout ${GRAMINE_COMMIT}
meson setup build/ --buildtype=release -Ddirect=enabled -Dsgx=enabled
ninja -C build/
ninja -C build/ install

export PATH="/usr/local/bin/:$PATH" # to identify the gramine binaries
gramine-sgx-gen-private-key

# Get gramine-tdx for the candle example
# we need the gramine-tdx specifically for that
cd /root
git clone ${GRAMINE_TDX_GIT_URL}
cd /root/gramine-tdx
git checkout dimakuv/add-candle-rust-example
git cherry-pick 044937e548dc61532833f969ec43e8929e495c99

# Setup the candle example
apt install cargo -y
mkdir -p /root/gramine-tdx/CI-Examples/candle/results
cd /root/gramine-tdx/CI-Examples/candle
make SGX=1

#Get the Gramine examples
cd /root
git clone ${GRAMINE_EXAMPLES_GIT_URL}
cd /root/examples
git checkout ${GRAMINE_EXAMPLES_COMMIT}
# cherry pick commits that add the Go and Java benchmarks
git remote add new_benchmarks https://github.com/dimstav23/gramine-examples.git
git fetch new_benchmarks
git cherry-pick 04ee033f986310d9822cb1cbd8a1d9087065498a
git cherry-pick 333301f03d662bca5d78ad398c052b643f40cf9b
git cherry-pick 818ecfb2a1ff2f71c46b951169608dcef5f7b829
git cherry-pick 5b13d3b65774213c18b3c6aca923b609fde4187d

#Setup the pytorch example
git apply /root/pytorch_benchmark.patch
apt install libnss-mdns libnss-myhostname -y
apt install python3-pip lsb-release -y
pip3 install torchvision pillow --break-system-packages
cd /root/examples/pytorch
mkdir results
python3 download-pretrained-model.py
make SGX=1

# Setup the openvino example
apt install libsm6 libxext6 libgl1 -y
apt install cmake python3 python3-venv -y
cd /root/examples
git apply /root/openvino_benchmark.patch
cd /root/examples/openvino
mkdir results
python3 -m venv openvino_env
source openvino_env/bin/activate
python -m pip install --upgrade pip
pip install openvino
deactivate
make SGX=1

# Setup the tensorflow example
apt install unzip -y
apt install python3-pip python-is-python3 -y
pip install tensorflow --break-system-packages
pip install psutil pandas future --break-system-packages
mkdir -p /root/examples/tensorflow
cd /root/examples/tensorflow
mkdir -p results
cp /root/Makefile ./
cp /root/python.manifest.template ./
make distclean
make install-dependencies-ubuntu
make SGX=1

# Setup the go bild example
apt install golang -y
cd /root/examples/bild
git apply /root/bild_benchmark.patch
mkdir -p results
make SGX=1

# Setup the Java image processing example
apt install openjdk-21-jdk -y
cd /root/examples/java_image
git apply /root/java_image_benchmark.patch
mkdir -p results
make SGX=1

# Apply the benchmark patches in the CI-Examples and build them (if needed)
# blender
apt install libxi6 libxxf86vm1 libxfixes3 libxrender1 -y
cd /root/gramine
git apply /root/blender_benchmark.patch
mkdir -p /root/gramine/CI-Examples/blender/results
cd /root/gramine/CI-Examples/blender
make

# redis
cd /root/gramine
git apply /root/redis_benchmark.patch
mkdir -p /root/gramine/CI-Examples/redis/results
cd /root/gramine/CI-Examples/redis
make SGX=1

# memcached
apt install libevent-dev -y
cd /root/gramine
git apply /root/memcached_benchmark.patch
mkdir -p /root/gramine/CI-Examples/memcached/results
cd /root/gramine/CI-Examples/memcached
make SGX=1

# sqlite-tmpfs
cd /root/gramine/CI-Examples/sqlite
git apply /root/sqlite-tmpfs_benchmark.patch
cp -r /root/gramine/CI-Examples/sqlite /root/gramine/CI-Examples/sqlite-tmpfs
mkdir -p /root/gramine/CI-Examples/sqlite-tmpfs/results
cd /root/gramine/CI-Examples/sqlite-tmpfs
cp /root/sqlite3.c  ./
cp /root/sqlite3.h  ./
# Note: kvtest.c is imported from the sqlite-tmpfs patch
make SGX=1

# sqlite
apt install sqlite3 -y
cd /root/gramine/CI-Examples/sqlite
git checkout Makefile manifest.template # modified by the sqlite-tmpfs patch
git apply /root/sqlite_benchmark.patch
mkdir -p /root/gramine/CI-Examples/sqlite/results
mv /root/sqlite3.c  ./
mv /root/sqlite3.h  ./
mv /root/kvtest.c   ./
make SGX=1

# python
apt install libnss-mdns python3-numpy python3-scipy python-is-python3 -y
cd /root/gramine
git apply /root/python_benchmark.patch
mkdir -p /root/gramine/CI-Examples/python/results
cd /root/gramine/CI-Examples/python
make SGX=1

# lighttpd
apt install build-essential libssl-dev zlib1g-dev libtool-bin wrk -y
cd /root/gramine
git apply /root/lighttpd_benchmark.patch
mkdir -p /root/gramine/CI-Examples/lighttpd/results
cd /root/gramine/CI-Examples/lighttpd
make distclean
make SGX=1
