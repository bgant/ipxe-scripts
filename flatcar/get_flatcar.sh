#!/bin/bash
#
# curl -LO https://kinvolk.io/flatcar-container-linux/security/image-signing-key/Flatcar_Image_Signing_Key.asc
# gpg --import Flatcar_Image_Signing_Key.asc
#

LATEST=`wget -q -O - https://stable.release.flatcar-linux.net/amd64-usr/ | grep '<span class="name">' | grep -v current | awk -F'>' '{print $2}' | awk -F'<' '{print $1}' | tail -n1`
CURRENT=`cat /nfs/wwwroot/release.txt`

if [ ${LATEST} != ${CURRENT} ]
then
    echo "Current Version is ${CURRENT}"
    echo "Version ${LATEST} is available... Downloading now..."
    cd /tmp

    echo
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz.sig
    gpg --verify flatcar_production_pxe.vmlinuz.sig flatcar_production_pxe.vmlinuz
    if [ $? == 0 ]  # gpg verification success is 0 and failure is 1
    then
        mv -v flatcar_production_pxe.vmlinuz /nfs/wwwroot/
        mv -v flatcar_production_pxe.vmlinuz.sig /nfs/wwwroot/
    else
        echo "gpg verification of flatcar_production_pxe.vmlinuz failed... Exiting"
        exit 0
    fi

    echo
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz.sig
    gpg --verify flatcar_production_pxe_image.cpio.gz.sig flatcar_production_pxe_image.cpio.gz
    if [ $? == 0 ]
    then
        mv -v flatcar_production_pxe_image.cpio.gz /nfs/wwwroot/
        mv -v flatcar_production_pxe_image.cpio.gz.sig /nfs/wwwroot/
    else
        echo "gpg verification of flatcar_production_pxe_image.cpio.gz failed... Exiting"
        exit 0
    fi

    echo ${LATEST} > /nfs/wwwroot/release.txt

else
    echo "Current Version is ${CURRENT}"
    echo "No new version available"
fi 
