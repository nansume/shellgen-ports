unset CPP  # cpp: fatal error: too many input files

local CTARGET=${CHOST}
local HOSTTYPE='i386'
local OSTYPE=${OSTYPE%%-*}

if test "X${ABI}" = 'Xx86'; then
  # <i686> - target may be inappropriate?
  CTARGET=${CHOST}  # unknow to appropriate <CHOST> ?
else
  CTARGET="${HOSTTYPE}-pc-${OSTYPE}"
fi
# required target: <i386-pc-linux-gnu>

MYCONF="${MYCONF}
 --target=$(usex 'pcbios' ${CTARGET} efi32)
 $(use_enable 'xz' liblzma)
 $(use_enable 'efiemu')
 --disable-werror
 --with-platform=$(usex 'pcbios' pc efi32)
"