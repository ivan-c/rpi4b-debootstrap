#! /bin/sh

umount /mnt/sd/boot
umount /mnt/sd

losetup -d /dev/loop0
# rm ~/images/rpi4.img
rm rpi4.img
