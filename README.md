# Scripts and Config files for Rancher Kubernetes Cluster

## iPXE: Boot ipxe.org Demo in QEMU/KVM with e1000 driver

The `demo.ipxe` script contains a few lines to boot a demo Linux kernel directly from the ipxe.org website just to verify everything is working properly:
```
#!ipxe
dhcp
chain http://boot.ipxe.org/demo/boot.php
```

From an **Ubuntu 18.04** VM or `sudo docker run -it ubuntu bash` container we build from source (http://ipxe.org/download) and embed (https://ipxe.org/embed) our ipxe script in the ROM image:
```
sudo apt-get install git build-essential liblzma-dev
git clone http://git.ipxe.org/ipxe.git
git clone https://github.com/bgant/ipxe-scripts
vi ipxe/src/config/general.h -OR- cp ipxe-scripts/ipxe/src/config/general.h ipxe/src/config/
cd ipxe/src/
make bin/8086100e.rom EMBED=../../ipxe-scripts/demo.ipxe
scp bin/8086100e.rom user@<QEMU Server IP>:
```
On the **QEMU/KVM server** your new ROM files can be anywhere and have any name, but I gave mine longer names and put them in with the rest of the QEMU ROM files:
```
mv 8086100e.rom /usr/share/qemu/ipxe-8086100e-e1000-demo.rom
virsh edit <VM Name>
   In the <interface type='direct'> network block
   <model type='e1000'/> 
   <rom file='/usr/share/qemu/ipxe-8086100e-e1000-demo.rom'/>
```

## iPXE: Boot RancherOS in QEMU/KVM with virtio driver

You can boot the latest version of RacherOS to run Docker containers using their embedded iPXE script:<br>
https://rancher.com/docs/os/v1.x/en/installation/running-rancheros/server/pxe/

From an **Ubuntu 18.04** VM or `sudo docker run -it ubuntu bash` container we build from source (http://ipxe.org/download) and embed (https://ipxe.org/embed) our ipxe script in the ROM image:
```
make bin/1af41000.rom EMBED=../../ipxe-scripts/RancherOS.ipxe
scp bin/1af41000.rom user@<QEMU Server IP>:
```

On the **QEMU/KVM server** your new ROM files can be anywhere and have any name:
```
mv 1af41000.rom /usr/share/qemu/ipxe-1af41000-virtio-RancherOS.rom
virsh edit <VM Name>
   In the <interface type='direct'> network block
   <model type='virtio'/> 
   <rom file='/usr/share/qemu/ipxe-1af41000-virtio-RancherOS.rom'/>
```

## iPXE: Tips
* The default iPXE ROM files loaded by QEMU are `/usr/share/qemu/efi-e1000.rom` and `efi-virtio.rom`
* Hit Ctrl+B when `efi-e1000.rom` or `efi-virtio.rom` are loading to get the `iPXE>` prompt
  * Lots of iPXE commands you can use: http://ipxe.org/cmd
* `make bin/virtio-net.rom` compiles but this rom does not appear to work in QEMU
* A list of all iPXE network drivers can be found here: http://ipxe.org/appnote/hardware_drivers
* Type `lspci -k` to see your Ethernet card and driver numbers
  * i.e. `00:03.0 Class 0200: 8086:100e e1000` is a QEMU VM using the e1000 network device model
  * i.e. `00:03.0 Class 0200: 1af4:1000 virtio-pci` is a QEMU VM using the virtio network device model
  * The `xxxx:yyyy` hex numbers are used to compile new rom files with `make bin/xxxxyyyy.rom` 
  * Here is a list of everything you can compile in iPXE: http://ipxe.org/appnote/buildtargets
  * The `iPXE 1.0.0+ (<commit>)` version is displayed where `<commit>` is the first letters of the last code commit when the ROM was compiled (https://git.ipxe.org/ipxe.git/log/)
* Instructions for creating new **VMware** iPXE ROM's can be found here: http://ipxe.org/howto/vmware 
* If you need to reduce the size of your ROM edit `ipxe/src/config/general.h` to disable components:
  * Change lines with `#define` to `#undef` or `//#define` to comment them out of your builds to free up space
* Great information on flashing a new iPXE ROM to a **Physical Network Card**:<br>https://www.richud.com/wiki/Network_gPXE_and_iPXE_Flashrom_Intel_Pro_100
