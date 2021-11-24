#!/bin/bash
#
# curl -LO https://kinvolk.io/flatcar-container-linux/security/image-signing-key/Flatcar_Image_Signing_Key.asc
# gpg --import Flatcar_Image_Signing_Key.asc
#

LATEST=`wget -q -O - https://stable.release.flatcar-linux.net/amd64-usr/ | grep '<span class="name">' | grep -v current | awk -F'>' '{print $2}' | awk -F'<' '{print $1}' | tail -n1`
CURRENT=`cat /nfs/wwwroot/release.txt`
echo "${CURRENT} is the Current Version"

if [ ${LATEST} != ${CURRENT} ]
then
    echo "${LATEST} is available... Downloading to /tmp now..."
    echo

    # Download all files first
    cd /tmp
    if [ `ls -1 | grep -c flatcar_production_pxe` != 0 ]  # Delete any previously downloaded files
    then
        rm flatcar_production_pxe*
    fi
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz.sig
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz
    wget https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz.sig

    # Verify files before making available to servers for network boot
    gpg --verify flatcar_production_pxe.vmlinuz.sig flatcar_production_pxe.vmlinuz
    KERNEL=$?
    echo
    gpg --verify flatcar_production_pxe_image.cpio.gz.sig flatcar_production_pxe_image.cpio.gz
    IMAGE=$?
    echo

    if [ $KERNEL == 0 ] && [ $IMAGE == 0 ]  # gpg verification success is 0 and failure is 1
    then
        echo "gpg verification success... replacing files in /nfs/wwwroot/"
        mv -v flatcar_production_pxe.vmlinuz /nfs/wwwroot/
        mv -v flatcar_production_pxe.vmlinuz.sig /nfs/wwwroot/
        mv -v flatcar_production_pxe_image.cpio.gz /nfs/wwwroot/                                       
        mv -v flatcar_production_pxe_image.cpio.gz.sig /nfs/wwwroot/
    else
        echo "gpg verification failed... Exiting"
        exit 0
    fi

    # Update release.txt with latest version
    echo ${LATEST} > /nfs/wwwroot/release.txt

else
    echo "No new version available"
fi 
