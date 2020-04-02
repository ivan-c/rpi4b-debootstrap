#! /bin/sh -e

if [ ! -f rpi4.img ]; then
    fallocate --length 3GiB rpi4.img
fi

loopback_devices=$(losetup -l --noheading)
if [ -z "$loopback_devices" ]; then
    losetup -f -P rpi4.img
fi


loopback_device=$(losetup -l  | grep rpi4 | awk '{print $1}')
parted --script --align optimal "$loopback_device" -- \
    mklabel msdos \
    mkpart primary fat32 1 128MiB \
    mkpart primary ext4 128MiB 100% set 1 boot

mkfs.vfat -F 32 /dev/loop0p1
mkfs.ext4 /dev/loop0p2

test -d /mnt/sd || mkdir -p /mnt/sd
mount /dev/loop0p2 /mnt/sd
test -d /mnt/sd/boot || mkdir /mnt/sd/boot

test -d /mnt/sd_boot || mkdir -p /mnt/sd_boot
mount /dev/loop0p1 /mnt/sd_boot

mount --bind /mnt/sd_boot /mnt/sd/boot


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

cp provision-boot.sh /mnt/sd/usr/bin/
chroot /mnt/sd/ /usr/bin/provision-boot.sh

# remove file identifying as chroot
rm /mnt/sd/etc/debian_chroot
