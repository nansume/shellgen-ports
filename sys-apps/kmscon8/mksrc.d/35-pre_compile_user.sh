#!/bin/sh
# -static -static-libs +shared -static-libgcc +nopie -lfs -upx +patch -doc -xstub -diet +musl +stest +strip +x32

FILESDIR=${FILESDIR:-$DISTSOURCE}
BUILD_DIR=${BUILD_DIR:-$WORKDIR}

test "${BUILD_CHROOT:=0}" -ne '0' || return 0

# BUG: linking against <libdrm.so> with static build
#[ "X${USER}" = 'Xroot' ] &&
#rm -- /$(get_libdir)/libdrm*.so* /$(get_libdir)/libdrm*.la /$(get_libdir)/pkgconfig/libdrm*.pc

[ "X${USER}" != 'Xroot' ] || return 0

cd ${BUILD_DIR}/ || return

# BUG: linking against <libdrm.so> with static build
#use 'static' || sed -e '/^shrext_cmds=/ s|.so||' -i libtool

case $(tc-chost) in
  *'-muslx32'|*'-gnux32')
    sed -e '/^LD =/ s|/ld -m elf_i386$|/ld -m elf32_x86_64|' -i Makefile
    printf %s\\n "libtool here no compatible... fix"
  ;;
esac
