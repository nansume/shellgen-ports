#!/bin/sh
# +static -static-libs -shared -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

inherit multilib install-functions

DESCRIPTION="Suspend and hibernation utilities"
HOMEPAGE="https://pm-utils.freedesktop.org/"
LICENSE="GPL-2"
IUSE="-alsa -debug -ntp -video_cards_intel -video_cards_radeon"
DOCS="AUTHORS ChangeLog NEWS pm/HOWTO* README* TODO"
EPREFIX=${EPREFIX:-$SPREFIX}
FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}
ED=${ED:-$INSTALL_DIR}
T=${BUILD_DIR}
CBUILD=$(tc-chost)
CHOST=$(tc-chost)

export PN PV ED EPREFIX CC CXX CBUILD CHOST

local IFS="$(printf '\n\t') "; local EPREFIX=${EPREFIX%/}
local ignore="01grub"

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

cd ${BUILD_DIR}/ || return

cp -L -f "${FILESDIR}"/50unload_alx -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/pci_devices -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/pm-utils.logrotate -t "${FILESDIR}"/
cp -L -f "${FILESDIR}"/usb_bluetooth -t "${FILESDIR}"/

use 'ntp' || ignore="${ignore}${ignore:+ }90clock"

use 'debug' && echo 'PM_DEBUG="true"' > "${T}"/gentoo
echo "HOOK_BLACKLIST=\"${ignore}\"" >> "${T}"/gentoo

econf \
  --bindir="${EPREFIX%/}/bin" \
  --sbindir="${EPREFIX%/}/sbin" \
  --includedir="${INCDIR}" \
  --libexecdir="${DPREFIX}/libexec" \
  --datarootdir="${DPREFIX}/share" \
  --disable-doc \
  || die "configure... error"

printf "Configure directory: ${PWD}/... ok\n"

make \
  DESTDIR=${ED} \
  prefix="${EPREFIX}"/usr \
  exec_prefix="${EPREFIX}" \
  all install \
  || die "make install... error"

rm -- Makefile

doman man/*.1 man/*.8

# Remove duplicate documentation install
#rm -r "${ED}"/usr/share/doc/${PN}

insinto /etc/pm/config.d
doins "${T}"/gentoo

insinto /etc/logrotate.d
newins "${FILESDIR}"/${PN}.logrotate ${PN} #408091

exeinto /$(get_libdir)/${PN}/sleep.d
doexe "${FILESDIR}"/50unload_alx

exeinto /$(get_libdir)/${PN}/power.d
doexe "${FILESDIR}"/pci_devices
doexe "${FILESDIR}"/usb_bluetooth

# No longer required with current networkmanager (rm -f from debian/rules)
rm -f "${ED}"/$(get_libdir)/${PN}/sleep.d/55NetworkManager

# No longer required with current kernels (rm -f from debian/rules)
rm -f "${ED}"/$(get_libdir)/${PN}/sleep.d/49bluetooth

# Punt HAL related file wrt #401257 (rm -f from debian/rules)
rm -f "${ED}"/$(get_libdir)/${PN}/power.d/hal-cd-polling

# Punt hooks which have shown to not reduce, or even increase power usage
# (rm -f from debian rules)
rm -f "${ED}"/$(get_libdir)/${PN}/power.d/journal-commit
rm -f "${ED}"/$(get_libdir)/${PN}/power.d/readahead

# Remove hooks which are not stable enough yet (rm -f from debian/rules)
rm -f "${ED}"/$(get_libdir)/${PN}/power.d/harddrive

# Change to executable (chmod +x from debian/rules)
fperms +x /$(get_libdir)/${PN}/defaults
