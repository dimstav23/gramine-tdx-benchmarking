#!/usr/bin/bash

set -ex

export LIBGUESTFS_BACKEND=direct

THIS_DIR=$(dirname "$(readlink -f "$0")")

# Make sure that the tdx submodule is initialized
pushd ${THIS_DIR}
git submodule update --init --recursive
popd

IMG_DIR=${THIS_DIR}/tdx/guest-tools/image
BASE_IMG=ubuntu-24.04-server-cloudimg-amd64.img
IMG_URL=https://cloud-images.ubuntu.com/releases/noble/release/${BASE_IMG}
CLOUD_IMG=${IMG_DIR}/${BASE_IMG}
TD_IMG=${IMG_DIR}/tdx-guest-ubuntu-24.04-generic.qcow2

DEPS_DIR=${THIS_DIR}/../bare-metal/deps

INIT_SCRIPT=""

usage() {
    cat << EOM
Usage: $(basename "$0") [OPTION]...
  -s <init_script>      Script to run as an init phase for the VM.
EOM
}

while getopts ":s:" option; do
    case "${option}" in
        s) INIT_SCRIPT=$OPTARG;;
        *)
            usage
            exit 1
            ;;
    esac
done

if [[ ! -f ${INIT_SCRIPT} ]]; then
    echo "Please provide an existing init script or \
use the default vm_image_init.sh script"
    usage
    exit 1
fi

if [[ ! -d ${IMG_DIR} ]] ; then
    echo "${IMG_DIR} does not exist, please make sure the canonical tdx submodule is initialized"
    exit 1
fi

if [[ ! -d ${DEPS_DIR} ]] ; then
    echo "${DEPS_DIR} does not exist, please make sure that you have the bare metal dependencies install"
    echo "To do so, please consult the README located in the following directory: ${THIS_DIR}"
    exit 1
fi

if ! command -v "virt-customize" ; then
    echo "virt-customize not found, please install libguestfs-tools"
    exit 1
fi

if [[ ! -f ${CLOUD_IMG} ]] ; then
    pushd ${IMG_DIR}
    wget ${IMG_URL}
    popd
fi

if [[ ! -f ${TD_IMG} ]] ; then
    pushd ${IMG_DIR}
    sudo ./create-td-image.sh
    popd
fi

virt-customize -a ${TD_IMG} --root-password password:123456
qemu-img resize ${TD_IMG} +40G

ARGS=" -a ${TD_IMG} -x"

# Setup guest environments
ARGS+=" --copy-in /etc/environment:/etc"
ARGS+=" --copy-in netplan.yaml:/etc/netplan/"
# ARGS+=" --copy-in ${REPO_LOCAL}:/srv/"
ARGS+=" --edit '/etc/ssh/sshd_config:s/#PermitRootLogin prohibit-password/PermitRootLogin yes/'"
ARGS+=" --edit '/etc/ssh/sshd_config:s/PasswordAuthentication no/PasswordAuthentication yes/'"
ARGS+=" --run-command 'growpart /dev/sda 1'"
ARGS+=" --run-command 'resize2fs /dev/sda1'"
ARGS+=" --run-command 'ssh-keygen -A'"
# ARGS+=" --run-command 'dpkg -i /srv/${REPO_NAME}/linux-*.deb'"
ARGS+=" --run-command 'systemctl mask pollinate.service'"

# Copy the stable-commits file
ARGS+=" --copy-in ${THIS_DIR}/../stable-commits:/root/"

# Copy the gramine patches
ARGS+=" --copy-in ${THIS_DIR}/../../pytorch/pytorch_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../blender/blender_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../redis/redis_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../memcached/memcached_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../sqlite/sqlite_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../sqlite-tmpfs/sqlite-tmpfs_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../openvino/openvino_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../python/python_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../lighttpd/lighttpd_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../bild/bild_benchmark.patch:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../../java_image/java_image_benchmark.patch:/root/"

# Copy misc files needed for the benchmarks
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/examples/tensorflow/Makefile:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/examples/tensorflow/python.manifest.template:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/sqlite/build/sqlite3.c:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/sqlite/build/sqlite3.h:/root/"
ARGS+=" --copy-in ${THIS_DIR}/../bare-metal/deps/sqlite/test/kvtest.c:/root/"

# Copy the init script and run it after the initial guest setup
ARGS+=" --copy-in ${INIT_SCRIPT}:/root/"
ARGS+=" --memsize 16384" # to avoid running out of memory during the init script exec
ARGS+=" --smp 32" # provide 16 cores for the run scripts to use
ARGS+=" --run-command '/root/${INIT_SCRIPT}'"

echo "${ARGS}"
eval virt-customize "${ARGS}"

