#!/bin/sh
set -ex
ISO=${1:-$(readlink -f boot2docker.iso)}
INITRD=${2:-$(readlink -f busybox-initrd.gz)}
TMPDIR=$(mktemp -d)
pushd $TMPDIR
function defer {
  popd
  cp $TMPDIR/xoxo.iso boot2docker-xoxo.iso
}
trap defer EXIT

apt-get install -qy xorriso syslinux

# extract original iso
osirrox -indev $ISO -extract / iso/
# patch logs
sed -i 's/loglevel=3/loglevel=7/' iso/boot/isolinux/isolinux.cfg
# replace initrd
cp $INITRD iso/boot/initrd.gz

# rebuild the iso
xorriso -as mkisofs -l -J -R -V boot2docker -no-emul-boot -boot-load-size 4 -boot-info-table -b /boot/isolinux/isolinux.bin -c /boot/isolinux/boot.cat -isohybrid-mbr /usr/lib/syslinux/isohdpfx.bin -o xoxo.iso iso/
