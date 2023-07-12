#!/bin/bash

set -xe
export DEBIAN_FRONTEND=noninteractive

pushd /tmp/
wget -nv https://github.com/jepio/AMDSEV/releases/download/v2023.05.25/linux-image-5.19.0-rc6-snp-host-46751c721588_5.19.0-rc6-snp-host-46751c721588-1_amd64.deb
wget -nv https://github.com/jepio/AMDSEV/releases/download/v2023.05.25/snp-qemu_2023.05.25-0_amd64.deb
apt-get update
apt-get install -y -f ./*.deb

rm *.deb
popd

mkdir -p /usr/local/sbin
wget -nv -O /usr/local/sbin/snphost https://github.com/jepio/AMDSEV/releases/download/v2023.05.25/snphost
chmod +x /usr/local/sbin/snphost

modprobe nbd
qemu-nbd -c /dev/nbd0 /usr/local/share/snp-qemu/*.qcow2
mount /dev/nbd0p1 /media/
pushd /media
mkdir -p usr/local/sbin
wget -nv -O usr/local/sbin/snpguest https://github.com/jepio/AMDSEV/releases/download/v2023.05.25/snpguest
chmod +x usr/local/sbin/snpguest
popd
umount /media
qemu-nbd -d /dev/nbd0

/usr/sbin/waagent -force -deprovision+user && export HISTSIZE=0 && sync

fstrim -va
