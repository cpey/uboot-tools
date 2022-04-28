#!/bin/bash

# BeagleBone Black microSD setup script. Adapted from [1, 2].
# [1] https://forum.digikey.com/t/debian-getting-started-with-the-beaglebone-black/12967#BeagleBoneBlack-Bootloader%3aU-Boot
# [2] https://wiki.beyondlogic.org/index.php?title=BeagleBoneBlack_Upgrading_uBoot

set -ex

KERNEL_VERSION=5.15.26-bone21
ROOT_DIR=~/beagleboneblack
DISK=/dev/mmcblk0
PARTITION_NO=p1
UBOOT=${ROOT_DIR}/u-boot/build/
ROOTFS=${ROOT_DIR}/debian-11.2-minimal-armhf-2021-12-20/armhf-rootfs-debian-bullseye.tar
ROOTFS_MOUNT_POINT=rootfs
KERNEL_DIR=${ROOT_DIR}/bb-kernel
SSH_KEY_PUB=id_ed25519_bb.pub
VBOOT=${ROOT_DIR}/verified-boot/out1

FIT_IMAGE=0
BOOT_ONLY=0
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -f|--fit-image)
            FIT_IMAGE=1
            shift
            ;;
        -b|--bootloader-only)
            BOOT_ONLY=1
            shift
            ;;
        *)
            echo "Invalid argument"
            exit 1
            ;;
    esac
done

function remove_sdcard ()
{
	sync
	sudo umount ${ROOTFS_MOUNT_POINT}
    rm -r ${ROOTFS_MOUNT_POINT}
}

function trap_ctrlc ()
{
    echo "Exiting..."
	remove_sdcard
    exit 130
}
trap "trap_ctrlc" 2

function flash_bootloader ()
{
    # SPL/MLO: sector #256 (0x20000)
    sudo dd if=${UBOOT}/MLO of=${DISK} bs=512 seek=256 count=256 conv=notrunc
    # U-Boot: sector #768 (0x60000)
    sudo dd if=${UBOOT}/u-boot-dtb.img of=${DISK} bs=512 seek=768 count=2048 conv=notrunc
}

if [[ ${BOOT_ONLY} -eq 1 ]]; then
    flash_bootloader
    exit 0
fi

# Erase partition table/labels on microSD card and program bootloader
sudo dd if=/dev/zero of=${DISK} bs=1M count=10
flash_bootloader

# Create Partition Layout
sudo sfdisk ${DISK} <<-__EOF__
4M,,L,*
__EOF__

# Format Partition
sudo mkfs.ext4 -L rootfs -O ^metadata_csum,^64bit ${DISK}${PARTITION_NO}

# Mount Partition
[[ -d ${ROOTFS_MOUNT_POINT} ]] && rm -r ${ROOTFS_MOUNT_POINT}
mkdir ${ROOTFS_MOUNT_POINT}
sudo mount ${DISK}${PARTITION_NO} ${ROOTFS_MOUNT_POINT}

# Backup bootloader
sudo mkdir -p ${ROOTFS_MOUNT_POINT}/opt/backup/uboot/
sudo cp -v ${UBOOT}/MLO ${ROOTFS_MOUNT_POINT}/opt/backup/uboot/
sudo cp -v ${UBOOT}/u-boot-dtb.img ${ROOTFS_MOUNT_POINT}/opt/backup/uboot/

# Copy Root File System
sudo tar xfvp ${ROOTFS} -C ${ROOTFS_MOUNT_POINT}
sync

# Set uname_r in /boot/uEnv.txt
sudo sh -c "echo 'uname_r=${KERNEL_VERSION}' >> ${ROOTFS_MOUNT_POINT}/boot/uEnv.txt"

# Copy Kernel Image
if [[ ${FIT_IMAGE} -eq 0 ]]; then
	sudo cp -v ${KERNEL_DIR}/deploy/${KERNEL_VERSION}.zImage ${ROOTFS_MOUNT_POINT}/boot/vmlinuz-${KERNEL_VERSION}
else
	sudo cp -v $VBOOT/image.fit ${ROOTFS_MOUNT_POINT}/boot/image.fit
fi

# Copy Kernel Device Tree Binaries
sudo mkdir -p ${ROOTFS_MOUNT_POINT}/boot/dtbs/${KERNEL_VERSION}/
sudo tar xfv ${KERNEL_DIR}/deploy/${KERNEL_VERSION}-dtbs.tar.gz -C ${ROOTFS_MOUNT_POINT}/boot/dtbs/${KERNEL_VERSION}/

# Copy Kernel Modules
sudo tar xfv ${KERNEL_DIR}/deploy/${KERNEL_VERSION}-modules.tar.gz -C ${ROOTFS_MOUNT_POINT}

# Filesystem table
sudo sh -c "echo '${DISK}${PARTITION_NO}  /  auto  errors=remount-ro  0  1' >> ${ROOTFS_MOUNT_POINT}/etc/fstab"

# Networking
sudo sh -c "echo -e 'auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address 192.168.0.1
    netmask 255.255.255.0
    gateway 192.168.0.2
    dns-nameserver 8.8.8.8' > ${ROOTFS_MOUNT_POINT}/etc/network/interfaces"

sudo mkdir ${ROOTFS_MOUNT_POINT}/home/debian/.ssh
sudo sh -c "cat $SSH_KEY_PUB > ${ROOTFS_MOUNT_POINT}/home/debian/.ssh/authorized_keys"
sed -i "/192.168.0.1 .*$/d" ~/.ssh/known_hosts

remove_sdcard
