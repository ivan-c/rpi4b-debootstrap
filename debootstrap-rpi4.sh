#! /bin/sh

if [ ! -f rpi4.img ]; then
    fallocate --length 3GiB rpi4.img
fi

loopback_devices=$(losetup -l --noheading)
if [ -z "$loopback_devices" ]; then
    losetup -f -P rpi4.img
fi


loopback_device=$(losetup -l  | grep rpi4 | awk '{print $1}')
parted -s --align optimal "$loopback_device" -- \
    mklabel msdos \
    mkpart primary boot fat32 1 128MiB \
    mkpart primary rootfs ext4 128MiB 100% \
    set 1 boot

mkfs.vfat -F 32 /dev/loop0p1
mkfs.ext4 /dev/loop0p2

mount /dev/loop0p2 /mnt/sd
mkdir /mnt/sd/boot
mount /dev/loop0p1 /mnt/sd/boot


#losetup -d /dev/loop0
#rm rpi4.img

# debootstrap --arch arm64 buster /mnt/sd
qemu-debootstrap --arch=arm64 --keyring /usr/share/keyrings/debian-archive-keyring.gpg --variant=buildd --exclude=debfoster buster /mnt/sd http://ftp.debian.org/debian



echo done running debootstrap

cat << EOF > /mnt/sd/etc/apt/sources.list
# deb http://http.us.debian.org/debian buster main

deb http://http.us.debian.org/debian buster main non-free
deb-src http://http.us.debian.org/debian buster main non-free

deb http://security.debian.org/debian-security buster/updates main non-free
deb-src http://security.debian.org/debian-security buster/updates main non-free

# buster-updates, previously known as 'volatile'
deb http://http.us.debian.org/debian buster-updates main non-free
deb-src http://http.us.debian.org/debian buster-updates main non-free
EOF



# mount -t devpts -o gid=5,mode=620 devpts /mnt/sd/dev/pts


mkdir -p /mnt/sd/tmp/
cp provision.sh /mnt/sd/usr/bin/

# pass proxy to chroot
if [ -n "$http_proxy" ]; then
    proxy_vars="http_proxy=${http_proxy}"
fi

# reuse given http proxy
schroot --chroot debootstrap-rpi4 -u root -- sh -c "${proxy_vars} provision.sh"
