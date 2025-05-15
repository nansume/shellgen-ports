####  1a7a4479796474ebfc2991ea3eeb62a3dd7375cc427089bb474d6c13dd732307  qemu-2.0.2.tar.xz

[https://download.qemu.org/qemu-1.7.2.tar.xz]
[https://download.qemu.org/qemu-2.0.2.tar.xz]

build deps:
===================================
# qemu sdl deps
directfb
gcc
pixman
libx11
libxau
libxdmcp
libaio
libbsd
libusb
libxcb
sdl
fold
===================================

#seabios -seavgabios
ipxe -qemu
qemu -pin-upstream-blobs -vhost-net

#python2 sqlite
qemu ncurses python2 -sdl -sdl2 -usb
qemu -alsa -bzip2 -caps -curl -fdt -filecaps -gtk -jpeg -nls -opengl -png -vnc

===================================
MYCONF=(${MYCONF[@]%--build=*})
MYCONF=(${MYCONF[@]%--host=*})
MYCONF+=(
 --enable-curses
 #--without-pixman
 --disable-tools
 --disable-system
 --disable-attr
 --audio-drv-list=
 --disable-coroutine-pool
 --disable-docs
 --disable-fdt
 --disable-guest-agent
 #--disable-guest-base
 --disable-kvm
 --disable-qom-cast-debug
 --disable-user
 --disable-vhost-net
 #--disable-vhost-scsi
 --disable-vnc
 --target-list='x86_64-softmmu'
)
===================================


removelist: mksrc.d/32-pkg_defconfig.sh

rmlist:
=========================================================
etc/*
lib/*
bin/ivshmem-client
bin/ivshmem-server
bin/<PN>-i*
bin/<PN>-nbd
<DPREFIX>/libexec
<DPREFIX>/share/<PN>/acpi-dsdt.aml
<DPREFIX>/share/<PN>/bamboo.dtb
<DPREFIX>/share/<PN>/bios-256k.bin
<DPREFIX>/share/<PN>/efi-*.rom
<DPREFIX>/share/<PN>/keymaps/ar
<DPREFIX>/share/<PN>/keymaps/bepo
<DPREFIX>/share/<PN>/keymaps/c*
<DPREFIX>/share/<PN>/keymaps/d*
<DPREFIX>/share/<PN>/keymaps/en-gb
<DPREFIX>/share/<PN>/keymaps/es
<DPREFIX>/share/<PN>/keymaps/et
<DPREFIX>/share/<PN>/keymaps/f*
<DPREFIX>/share/<PN>/keymaps/h*
<DPREFIX>/share/<PN>/keymaps/i*
<DPREFIX>/share/<PN>/keymaps/ja
<DPREFIX>/share/<PN>/keymaps/l*
<DPREFIX>/share/<PN>/keymaps/m*
<DPREFIX>/share/<PN>/keymaps/n*
<DPREFIX>/share/<PN>/keymaps/p*
<DPREFIX>/share/<PN>/keymaps/r*
<DPREFIX>/share/<PN>/keymaps/s*
<DPREFIX>/share/<PN>/keymaps/t*
<DPREFIX>/share/<PN>/openbios-*
<DPREFIX>/share/<PN>/kvmvapic.bin
<DPREFIX>/share/<PN>/*boot*.bin
<DPREFIX>/share/<PN>/p*
<DPREFIX>/share/<PN>/QEMU,*.bin
<DPREFIX>/share/<PN>/<PN>*
<DPREFIX>/share/<PN>/s390-*.img
<DPREFIX>/share/<PN>/sgabios.bin
<DPREFIX>/share/<PN>/skiboot.lid
<DPREFIX>/share/<PN>/slof.bin
<DPREFIX>/share/<PN>/spapr-rtas.bin
<DPREFIX>/share/<PN>/trace-events-all
<DPREFIX>/share/<PN>/u-boot.e500
<DPREFIX>/share/<PN>/vgabios.bin
<DPREFIX>/share/<PN>/vgabios-cirrus.bin
<DPREFIX>/share/<PN>/vgabios-qxl.bin
<DPREFIX>/share/<PN>/vgabios-v*.bin
=========================================================