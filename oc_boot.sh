#!/usr/bin/env bash

# Usage examples:
# ./oc_boot.sh spag_oc.qcow2 spag_sonoma.img
# ./oc_boot.sh spag_oc.qcow2 spag_sonoma.img 2223 5901
# ./oc_boot.sh spag_oc.qcow2 spag_ventura.img 2224 5902 --ventura

# Ensure at least two arguments (the qcow2 bootloader and macOS disk image) are passed
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <bootloader.qcow2> <macos_disk.img> [ssh_port] [spice_port] [--ventura]"
    exit 1
fi

BOOTLOADER="$1"
MAC_HDD="$2"

# Default to 2222 if not provided
SSH_PORT="${3:-2222}"       

# Default to 5900 if not provided
SPICE_PORT="${4:-5900}"     

# Last optional parameter
OPTIONAL_PARAM="${5:-}"     

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"
ALLOCATED_RAM="32768" # MiB
CPU_SOCKETS="1"
CPU_CORES="4"
CPU_THREADS="8"

# Set the default CPU model for Sonoma
CPU_MODEL="Haswell-noTSX"

# Check if the optional --ventura flag is provided to switch to Penryn CPU for Ventura
if [ "$OPTIONAL_PARAM" == "--ventura" ]; then
    CPU_MODEL="Penryn"
    echo "Using Penryn CPU model for Ventura."
else
    echo "Using Haswell-noTSX CPU model for Sonoma."
fi

# shellcheck disable=SC2054
args=(
  -enable-kvm -m "$ALLOCATED_RAM"

  # Set the CPU model and options
  -cpu "$CPU_MODEL",kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,"$MY_OPTIONS"

  -machine q35
  -device qemu-xhci,id=xhci
  -device usb-kbd,bus=xhci.0 -device usb-tablet,bus=xhci.0
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS"

  # Apple SMC device (required for macOS)
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"

  # EFI Boot files
  -drive if=pflash,format=raw,readonly=on,file="./OVMF_CODE.fd"

  -smbios type=2

  # Audio device
  -device ich9-intel-hda -device hda-duplex

  # Main macOS disk and OpenCore bootloader
  -device ich9-ahci,id=sata
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$BOOTLOADER"
  -device ide-hd,bus=sata.2,drive=OpenCoreBoot,bootindex=1

  -drive id=MacHDD,if=none,file="$MAC_HDD",format=qcow2
  -device ide-hd,bus=sata.4,drive=MacHDD

  # Networking + port forwarding for SSH
  -netdev user,id=net0,hostfwd=tcp::"$SSH_PORT"-:22 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27

  # Monitor and graphics
  -monitor stdio
  -device vmware-svga

  # SPICE display server on localhost with port forwarding to LAN
  -spice port="$SPICE_PORT",addr=127.0.0.1,disable-ticketing=on
)

# Port forwarding for SSH
sudo iptables -t nat -A PREROUTING -p tcp --dport "$SSH_PORT" -j DNAT --to-destination 127.0.0.1:"$SSH_PORT"
sudo iptables -t nat -A POSTROUTING -p tcp -d 127.0.0.1 --dport "$SSH_PORT" -j MASQUERADE

# Port forwarding for SPICE
sudo iptables -t nat -A PREROUTING -p tcp --dport "$SPICE_PORT" -j DNAT --to-destination 127.0.0.1:"$SPICE_PORT"
sudo iptables -t nat -A POSTROUTING -p tcp -d 127.0.0.1 --dport "$SPICE_PORT" -j MASQUERADE

qemu-system-x86_64 "${args[@]}"
