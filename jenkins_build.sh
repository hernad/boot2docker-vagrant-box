#!/bin/bash

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


chmod +x packer
./packer build -debug -var 'headless=true' -only=virtualbox-iso template.json

mv ${IMG}_virtualbox.box ${IMG}_$(date +"%Y-%m-%d").box
