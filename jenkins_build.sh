#!/bin/bash

DOWNLOAD_URL=http://download.bring.out.ba

if [ ! -f packer.zip ] ; then
  curl -L https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip?_ga=1.155119281.822261056.1493217676 > packer.zip
  unzip packer.zip
fi

IMG=greenbox

if VBoxManage list vms | grep -q ${IMG}
then
 rm -rf packer-${IMG}-virtualbox
 # ako je na silu prosli put prekinuto
 VBoxManage controlvm ${IMG} poweroff
 VBoxManage unregistervm ${IMG} --delete
 VBoxManage unregistervm ${IMG} --delete
fi

rm -rf "/home/docker/VirtualBox VMs/${IMG}"

curl -LO https://raw.githubusercontent.com/hernad/greenbox/apps_modular/GREENBOX_VERSION
if [ $? != 0 ] ; then
  echo "cannot get GREENBOX_VERSION"
  exit 1
fi

GREENBOX_VERSION=`cat GREENBOX_VERSION || sed -e 's/\n//'`
curl -LO $DOWNLOAD_URL/greenbox-${GREENBOX_VERSION}.iso.sha256sum
SHA256SUM=`cat greenbox-${GREENBOX_VERSION}.iso.sha256sum || sed -e 's/\n//'`

chmod +x packer

echo "GREENBOX_VERSION=$GREENBOX_VERSION CHECKSUM=$SHA256SUM"

VARS="-var 'headless=true' "
VARS+=" -var 'url=${DOWNLOAD_URL}/greenbox-${GREENBOX_VERSION}.iso"
VARS+=" -var 'checksum=${SHA256SUM}' -var 'version=${GREENBOX_VERSION}'"

echo packer vars=$VARS
 
./packer build \
  $VARS \
  -only=virtualbox-iso \
   template.json

mv ${IMG}_virtualbox.box ${IMG}_${GREENBOX_VERSION}.box
