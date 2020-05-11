#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 image_name"
    exit 1
fi

cd /virsh-ssd-pool/
echo "Deleting the previous box ${1}.box and image ${1}_vagrant_box_image_0.img from the virsh pool..."
sudo virsh vol-delete --pool virsh-ssd-pool ${1}.box
sudo virsh vol-delete --pool virsh-ssd-pool ${1}_vagrant_box_image_0.img
echo "Building the new image..."
sudo /usr/local/bin/create_box.sh ${1}.qcow2
echo "Removing the box from vagrant"
vagrant box remove ${1}
vagrant box add ${1}.box --name ${1}

cd ~
