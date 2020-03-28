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
    mkpart primary fat32 1 128MiB \
    mkpart primary ext4 128MiB 100% set 1 boot

#losetup -d /dev/loop0
#rm rpi4.img
debootstrap --arch arm64 buster /mnt/sd

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


echo "Mounting /dev/ and /dev/pts in chroot... "
mkdir -p -m 755 /mnt/sd/dev/pts
mount -t devtmpfs -o mode=0755,nosuid devtmpfs /mnt/sd/dev

mount --bind /dev/pts /mnt/sd/dev/pts
# mount -t devpts -o gid=5,mode=620 devpts /mnt/sd/dev/pts
echo "OK"

cp /usr/bin/qemu-aarch64-static /mnt/sd/usr/bin
mount -t proc /proc /mnt/sd/proc/
mount -t sysfs /sys /mnt/sd/sys/
mount -o bind /dev /mnt/sd/dev/

mkdir -p /mnt/sd/tmp/
cp provision.sh /mnt/sd/tmp/
