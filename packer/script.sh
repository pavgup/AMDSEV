#!/bin/bash

set -xe
export DEBIAN_FRONTEND=noninteractive

pushd /tmp/
wget -nv https://github.com/jepio/AMDSEV/releases/download/v2023.08.18/linux-image-6.5.0-rc2-snp-host-967d27d1acd2_6.5.0-rc2-g967d27d1acd2-2_amd64.deb
wget -nv https://github.com/jepio/AMDSEV/releases/download/v2023.08.18/snp-qemu_2023.08.29-0_amd64.deb
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
