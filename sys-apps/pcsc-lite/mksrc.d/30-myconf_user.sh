# -static -static-libs +shared +nopie -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="PC/SC Architecture smartcard middleware library"
HOMEPAGE="https://pcsclite.apdu.fr https://github.com/LudovicRousseau/PCSC"
LICENSE="BSD ISC MIT GPL-3+ GPL-2"
IUSE="-doc +embedded +libusb -policykit -selinux -systemd -udev +shared +nopie -lfs (+musl) +stest +strip"

MYCONF="${MYCONF}
 --enable-libusb
 --enable-embedded
 --enable-usbdropdir=/$(get_libdir)/readers/usb
 --enable-ipcdir=/run/pcscd
 --disable-maintainer-mode
 --disable-strict
 --disable-documentation
 --disable-libudev
 --disable-libsystemd
 --disable-polkit
"
