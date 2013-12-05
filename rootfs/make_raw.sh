#!/bin/sh
set -ex
TMPDIR=$(mktemp -d)
ISO=$(readlink -f ${1:-boot2docker.iso})
DISK_SIZE=${DISK_SIZE:-64M}
pushd $TMPDIR

function defer {
  set +e
  find iso
  find raw
  file disk.raw
  umount iso
  umount raw
  partx -d /dev/loop0
  losetup -d /dev/loop0
  popd
  cp $TMPDIR/disk.raw .
}
trap defer EXIT

# Bootstrap the image file with one partition
truncate disk.raw --size=$DISK_SIZE
parted disk.raw mklabel msdos
parted disk.raw mkpart primary ext4 1 $DISK_SIZE
parted disk.raw set 1 boot on

# Format and mount the image first partiion
losetup /dev/loop0 disk.raw
partx -a /dev/loop0
mkfs.ext4 /dev/loop0p1
mkdir -p raw
mount /dev/loop0p1 raw

# Mount boot2docker ISO image
mkdir -p iso
mount -o loop $ISO iso

# Copy kernel and rootfs from boot2docker ISO
mkdir -p raw/boot
cp iso/boot/vmlinuz64 raw/boot/vmlinuz64
cp iso/boot/initrd.gz raw/boot/initrd.gz

# Install grub
grub-install --boot-directory=raw/boot /dev/loop0
