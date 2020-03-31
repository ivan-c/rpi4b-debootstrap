#! /bin/sh

umount /mnt/sd/boot
umount /mnt/sd
umount /mnt/sd_boot

losetup -d /dev/loop0
# rm ~/images/rpi4.img
rm rpi4.img
