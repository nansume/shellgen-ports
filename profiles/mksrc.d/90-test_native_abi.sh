#!/bin/sh
# Date: 2023-10-21 20:00 UTC - fix: near to compat-posix, no-posix: local VAR

local XABI='all'; local ABI=${ABI}; local PLIST=; local P=

{ test "x${USER}" != 'xroot' || test "0${BUILD_CHROOT}" -ne '0' ;} && return

test -d "${INSTALL_DIR}" || exit
cd ${INSTALL_DIR}/

export INST_ABI=${ABI}

printf %s\\n "INST_ABI=${INST_ABI}" "ABI=${ABI}" "ABI_BUILD=${ABI_BUILD}"

ABI=${ABI_BUILD}; INST_ABI=${ABI}

for P in "bin/" "${LIB_DIR}/" "lib/" "sbin/" "opt/" "usr/libexec/"; do
  test -d "${P}" && PLIST="${PLIST:+${PLIST}${IFS}}$(globstar ${P})"
done

# skip it: [elf32-i386] for the <grub2> through the <bios-legacy>
# native may be: elf32_x86_64 [elf32-x86-64], elf64_x86_64 [elf64-x86-64], elf_i386 [elf32-i386]
for P in ${PLIST}; do
  case /${P} in
    *"/pkgconfig/"*".pc") XABI='all'; continue
    ;;
    *"/i386-pc/"*) XABI='all'; continue
      # skip: lib*/grub/i386-pc/*.mod [elf32-i386]
    ;;
    "/lib/"?*)
      XABI='all'
      # error: <LIB_DIR> != lib - correct of fix --> lib32
      test "X${ABI}" = 'Xx86' || continue
      XABI=${ABI}
    ;;
    "/${LIB_DIR}/"?*) XABI=${ABI}
    ;;
  esac
  if testelf ${P}; then
    XABI=${ABI}; break
  fi
done

test "X${XABI}" = 'Xall' && INST_ABI=${XABI}

printf %s\\n "New: INST_ABI=${INST_ABI}"
