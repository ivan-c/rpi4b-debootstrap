!# /bin/sh -e

apt update
apt upgrade

dpkg-reconfigure tzdata

apt install locales
dpkg-reconfigure locales

echo \
'auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf' \
> /etc/network/interfaces

echo \
'nameserver 1.1.1.1
nameserver 1.0.0.1' \
> /etc/resolv.conf

echo 'Pi-Example' > /etc/hostname

echo \
'127.0.0.1 localhost
127.0.1.1 Pi-Example

::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts' \
> /etc/hosts


cat << EOF > /etc/fstab
# <file system>   <dir>           <type>  <options>         <dump>  <pass>
proc              /proc           proc    defaults          0       0
/dev/mmcblk0p1    /boot           vfat    defaults          0       2
/dev/mmcblk0p2    /               ext4    defaults,noatime  0       1
EOF

apt install \
    ca-certificates \
    crda \
    fake-hwclock \
    firmware-brcm80211 \
    net-tools \
    ntp \
    usb-modeswitch \
    ssh \
    sudo \
    wget \
    wpasupplicant \
    xz-utils

cd /lib/firmware/brcm
wget https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/master/brcm/brcmfmac43455-sdio.txt
wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43455-sdio.clm_blob

useradd -s /bin/bash -d /home/debian -G sudo debian

cd /usr/local/bin
wget https://raw.githubusercontent.com/Hexxeh/rpi-update/master/rpi-update /usr/bin
chmod +x /usr/bin/rpi-update

apt install curl binutils

WANT_PI4=1 rpi-update

echo 'dwc_otg.lpm_enable=0 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline fsck.repair=yes rootwait net.ifnames=0' > /boot/cmdline.txt
echo $'kernel=kernel8.img\ngpu_mem=16\narm_64bit=1\ndtoverlay=vc4-fkms-v3d' > /boot/config.txt
