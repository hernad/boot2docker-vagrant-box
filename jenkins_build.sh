#!/bin/bash

DOWNLOAD_URL=http://download.bring.out.ba

if [ ! -f packer.zip ] ; then
  curl -L https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip?_ga=1.155119281.822261056.1493217676 > packer.zip
  unzip packer.zip
fi

IMG=greenbox
rm -rf packer-${IMG}-virtualbox
# ako je na silu prosli put prekinuto
VBoxManage controlvm ${IMG} poweroff
VBoxManage unregistervm ${IMG} --delete
VBoxManage unregistervm ${IMG} --delete

rm -rf "/home/docker/VirtualBox VMs/${IMG}"

curl -LO https://raw.githubusercontent.com/hernad/greenbox/apps_modular/GREENBOX_VERSION
if [ $? != 0 ] ; then
  echo "cannot get GREENBOX_VERSION"
  exit 1
fi

GREENBOX_VERSION=`cat GREENBOX_VERSION`
curl -LO $DOWNLOAD_URL/greenbox-${GREENBOX_VERSION}.iso.sha256sum
SHA256SUM=`cat greenbox-${GREENBOX_VERSION}.iso.sha256sum`

chmod +x packer

./packer build \
   -var 'headless=true' \
   -var "url=${DOWNLOAD_URL}/greenbox-$GREENBOX_VERSION.iso" \
   -var "checksum=${SHA256SUM}" \
   -var "version=${GREENBOX_VERSION}" \
   -only=virtualbox-iso \
   template.json

mv ${IMG}_virtualbox.box ${IMG}_${GREENBOX_VERSION}.box
