#! /bin/sh -e

set -x

# chroot

yes | WANT_PI4=1 rpi-update

echo 'dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait net.ifnames=0' > /boot/cmdline.txt
echo $'kernel=kernel8.img\ngpu_mem=16\narm_64bit=1\ndtoverlay=vc4-fkms-v3d' > /boot/config.txt
