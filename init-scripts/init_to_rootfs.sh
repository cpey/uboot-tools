#!/bin/sh

mount -t proc none /proc
mount -t sysfs none /sys

mknod /dev/loop0 b 7 0
mknod /dev/mmcblk0 b 179 0
mount /dev/mmcblk0 /mnt

mkdir /newroot
# mount -o loop,rw /mnt/rootfs.img /newroot
losetup /dev/loop0 /mnt/rootfs.img
mount /dev/loop0 /newroot
mount --move /sys /newroot/sys
mount --move /proc /newroot/proc
exec switch_root /newroot /sbin/init
