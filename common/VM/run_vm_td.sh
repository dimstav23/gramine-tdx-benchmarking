#!/bin/bash

# Custom file for launching VMs and TDs
# This script is based on the Canonical's TDX `run_td.sh` script
# Licensing information preserved below

# This file is part of Canonical's TDX repository which includes tools
# to setup and configure a confidential computing environment
# based on Intel TDX technology.
# See the LICENSE file in the repository for the license text.

# Copyright 2024 Canonical Ltd.
# SPDX-License-Identifier: GPL-3.0-only

# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3,
# as published by the Free Software Foundation.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranties
# of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.

CURR_DIR=$(readlink -f "$(dirname "$0")")

# VM configurations
CPUS=4
MEM=8G

cleanup() {
    rm -f /tmp/tdx-guest-*.log &> /dev/null
    rm -f /tmp/tdx-demo-*-monitor.sock &> /dev/null

    PID_TD=$(cat /tmp/tdx-demo-td-pid.pid 2> /dev/null)

    [ ! -z "$PID_TD" ] && echo "Cleanup, kill TD with PID: ${PID_TD}" && kill -TERM ${PID_TD} &> /dev/null
    sleep 3
}

cleanup
if [ "$1" = "clean" ]; then
    exit 0
fi

TDVF_FIRMWARE=/usr/share/ovmf/OVMF.fd
GUEST_IMG=""
DEFAULT_GUEST_IMG=${CURR_DIR}/tdx/guest-tools/image/tdx-guest-ubuntu-24.04-generic.qcow2
VM_TYPE="td"
TAP_NETWORK=false
SSH_FORWARD_PORT=10026
NET_CIDR="10.0.2.0/24"
DHCP_START="10.0.2.15"

# Just log message of serial into file without input
SETUP_CONSOLE="-chardev stdio,id=mux,mux=on,logfile=$CURR_DIR/vm_log_$(date +"%FT%H%M").log \
             -device virtio-serial,romfile= \
             -device virtconsole,chardev=mux"
            #  -monitor chardev:mux \
            #  -serial chardev:mux"
PROCESS_NAME=run_vm_td
LOGFILE='/tmp/tdx-guest-td.log'
QUOTE_ARGS="-device vhost-vsock-pci,guest-cid=3"

# Default template for QEMU command line
QEMU_EXEC="/usr/bin/qemu-system-x86_64"
QEMU_CMD="${QEMU_EXEC} -D ${LOGFILE} \
          -accel kvm \
          -name ${PROCESS_NAME},process=${PROCESS_NAME},debug-threads=on \
          -nographic \
          -nodefaults \
          ${QUOTE_ARGS} \
          -pidfile /tmp/tdx-demo-td-pid.pid"
PARAM_CPU=" -cpu host,-kvm-steal-time,pmu=off"
PARAM_MACHINE=" -machine q35"

usage() {
    cat << EOM
Usage: $(basename "$0") [OPTION]...
  -i <guest image file>     Default is ${CURR_DIR}/tdx/image/tdx-guest-ubuntu-24.04-generic.qcow2
  -t [efi|td]               VM Type, default is "td"
  -c <number>               Number of CPUs, default is 1
  -m <number[M|G]>          VM memory, default is 2G
  -l                        Flag to enable TAP networking
  -h                        Show this help
EOM
}

error() {
    echo -e "\e[1;31mERROR: $*\e[0;0m"
    exit 1
}

warn() {
    echo -e "\e[1;33mWARN: $*\e[0;0m"
}

if ! groups | grep -qw "kvm"; then
    echo "Please add user $USER to kvm group to run this script (usermod -aG kvm $USER and then log in again)."
    exit 1
fi

process_args() {
    while getopts ":i:t:m:lhc:" option; do
        case "$option" in
            i) GUEST_IMG=$OPTARG;;
            t) VM_TYPE=$OPTARG;;
            l) TAP_NETWORK=true;;
            c) CPUS=$OPTARG;;
            m) MEM=$OPTARG;;
            h) usage
               exit 0
               ;;
            *)
               echo "Invalid option '-$OPTARG'"
               usage
               exit 1
               ;;
        esac
    done

    # Validate the number of CPUs
    if ! [[ ${CPUS} =~ ^[0-9]+$ && ${CPUS} -gt 0 ]]; then
        error "Invalid number of CPUs: ${CPUS}"
    fi

    # Validate the amount of VM memory and EPC memory
    pattern="^[0-9]+[MG]$"
    if ! [[ ${MEM} =~ $pattern ]]; then
        error "Invalid amount of Memory specified: ${MEM}"
    fi

    # Validate the existence of the guest image
    GUEST_IMG="${GUEST_IMG:-${DEFAULT_GUEST_IMG}}"
    if [[ ! -f ${GUEST_IMG} ]]; then
        usage
        error "Guest image file ${GUEST_IMG} not exist. Please specify via option \"-i\""
    fi

    # Validate the existence of the firmware
    if [[ ! -f ${TDVF_FIRMWARE} ]]; then
        error "Could not find ${TDVF_FIRMWARE}. Please install TDVF(Trusted Domain Virtual Firmware)."
    fi

    # Check parameter MAC address
    if [[ -n ${MAC_ADDR} ]]; then
        if [[ ! ${MAC_ADDR} =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ ]]; then
            error "Invalid MAC address: ${MAC_ADDR}"
        fi
    fi

    case ${GUEST_IMG##*.} in
        qcow2) FORMAT="qcow2";;
          img) FORMAT="raw";;
            *) echo "Unknown disk image's format"; exit 1 ;;
    esac

    case ${VM_TYPE} in
        "td")
            # cpu_tsc=$(grep 'cpu MHz' /proc/cpuinfo | head -1 | awk -F: '{print $2/1024}')
            # if (( $(echo "$cpu_tsc < 1" |bc -l) )); then
            #     PARAM_CPU+=",tsc-freq=1000000000"
            # fi
            PARAM_MACHINE+=",kernel_irqchip=split,confidential-guest-support=tdx,hpet=off"
            QEMU_CMD+=" -object tdx-guest,id=tdx"
            QEMU_CMD+=" -bios ${TDVF_FIRMWARE}"
            ;;
        "efi")
            PARAM_MACHINE+=",kernel_irqchip=split,hpet=off"
            QEMU_CMD+=" -bios ${TDVF_FIRMWARE}"
            ;;
        *)
            error "Invalid ${VM_TYPE}, must be [efi|td]"
            ;;
    esac

    # QEMU_CMD+=" -drive file=$(readlink -f "${GUEST_IMG}"),if=virtio,format=$FORMAT "
    QEMU_CMD+=" -drive file=${GUEST_IMG},if=none,id=virtio-disk0"
    QEMU_CMD+=" -device virtio-blk-pci,drive=virtio-disk0"
    QEMU_CMD+=$PARAM_CPU
    QEMU_CMD+=$PARAM_MACHINE
    QEMU_CMD+=" -device virtio-net-pci,netdev=mynet0"

    # Set the network cidr, DHCP start address, and forward SSH port to the host 
    if [[ ${TAP_NETWORK} == true ]]; then
        QEMU_CMD+=" -netdev tap,id=mynet0,script=${CURR_DIR}/../../../qemu-ifup,downscript=${CURR_DIR}/../../../qemu-ifdown"
    else
        QEMU_CMD+=" -netdev user,id=mynet0,net=$NET_CIDR,dhcpstart=$DHCP_START,hostfwd=tcp::${SHH_FORWARD_PORT}-:22 "
    fi
    
    # Specify the number of CPUs
    QEMU_CMD+=" -smp ${CPUS} "

    # Specify the amount of Memory
    QEMU_CMD+=" -m ${MEM} "

    # Add the HVC console params
    QEMU_CMD+=" ${SETUP_CONSOLE} "

    echo "========================================="
    echo "Guest Image       : ${GUEST_IMG}"
    echo "OVMF              : ${TDVF_FIRMWARE}"
    echo "VM Type           : ${VM_TYPE}"
    echo "CPUS              : ${CPUS}"
    echo "Memory            : ${MEM}"
    
    if [[ -n ${MAC_ADDR} ]]; then
        echo "MAC Address       : ${MAC_ADDR}"
    fi
    if [[ ${TAP_NETWORK} == true ]]; then
        echo "TAP network       : ON"
    else
        echo "TAP network       : OFF"
    fi
    echo "========================================="
}

###################### RUN EFI/TD VM ##################################
launch_vm() {
    # remap CTRL-C to CTRL ]
    echo "Remapping CTRL-C to CTRL-]"
    stty intr ^]
    echo "Launch VM:"
    # shellcheck disable=SC2086,SC2090
    echo ${QEMU_CMD}
    # shellcheck disable=SC2086
    eval ${QEMU_CMD}
    # restore CTRL-C mapping
    stty intr ^c
}

process_args "$@"
# removed params: -daemonize, 
# added params: -kvm-steal-time,pmu=off
launch_vm
