#!/bin/sh
set -ex
TMPDIR=$(mktemp -d)
pushd $TMPDIR
function defer {
  popd
  cp $TMPDIR/rootfs.cpio.gz initrd.gz
  file initrd.gz
}
trap defer EXIT

wget http://busybox.net/downloads/binaries/latest/busybox-x86_64
chmod +x busybox-x86_64
mkdir -p rootfs/bin
./busybox-x86_64 --install rootfs/bin
cd rootfs
mkdir dev proc sys tmp
mknod dev/console c 5 1
cat >> init <<EOF
#!/bin/ash
mount -t proc none /proc
mount -t sysfs none /sys
/bin/ash
EOF
chmod +x init
find . | cpio -H newc -o | gzip > $TMPDIR/rootfs.cpio.gz
