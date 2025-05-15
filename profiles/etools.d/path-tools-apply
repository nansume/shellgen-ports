#!/bin/sh
# 2023-2024

. "${PDIR%/}/etools.d/"build-functions || { printf %s\\n "${SCNAME##*/}: [build-functions]... error" >&2; exit 1;}

#export PATH
#printf %s\n PATH=${PATH}

#set -- "$(xpath)"  # collision with <dev-perl/xml-xpath>, required fix. /bin/xpath -> /opt/libexec/
set -- "$(/opt/libexec/xpath)"

export PATH="${1:-${PATH:?not set: required... error}}"

test -d "${PDIR%/}/misc.d"    && PATH="${PATH:+${PATH}:}${PDIR%/}/misc.d"
test -d "${PDIR%/}/etools.d"  && PATH="${PATH:+${PATH}:}${PDIR%/}/etools.d"
test -d "${PDIR%/}/ecompat.d" && PATH="${PATH:+${PATH}:}${PDIR%/}/ecompat.d"
test -x "/$(get_libdir)/qt4/bin/qmake" && PATH="${PATH}${PATH:+:}/$(get_libdir)/qt4/bin"

for D in "${PDIR%/}/ecompat.d/"*/; do
  D=${D%/}
  test -d "${D}" || continue
  export PATH="${PATH}${PATH:+:}${D}"
done

test "X${USER}" != 'Xroot' && printf %s\\n "PATH='${PATH}'"

# required displace -> 17-ldpath_apply.sh
# bdirlib - required fix to $(bdirlib)
test "X${USER}" != 'Xroot' && { bdirlib; printf %s\\n "LD_LIBRARY_PATH='${LD_LIBRARY_PATH}'";}

unset D
