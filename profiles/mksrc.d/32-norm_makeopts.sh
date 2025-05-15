# Date: 2023-10-14 10:00 UTC - Log: create

local IFS="$(printf '\n\t')"; IFS="${IFS%?}"; local X

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

test "${BUILD_CHROOT:=0}" -ne '0' || return 0
{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

for X in '' ${MAKEFLAGS}; do
  test -z "${X}" && { MAKEFLAGS=; continue;}
  X="${X%%#*}"; X="${X#${X%%[![:space:]]*}}"
  test -n "${X}" && MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS} }${X%${X##*[![:space:]]}}"
done

for X in '' ${MYCONF}; do
  test -z "${X}" && { MYCONF=; continue;}
  X="${X%%#*}"; X="${X#${X%%[![:space:]]*}}"
  test -n "${X}" && MYCONF="${MYCONF:+${MYCONF} }${X%${X##*[![:space:]]}}"
done

for X in '' ${CMAKEFLAGS}; do
  test -z "${X}" && { CMAKEFLAGS=; continue;}
  X="${X%%#*}"; X="${X#${X%%[![:space:]]*}}"
  test -n "${X}" && CMAKEFLAGS="${CMAKEFLAGS:+${CMAKEFLAGS} }${X%${X##*[![:space:]]}}"
done

for X in '' ${MESON_FLAGS}; do
  test -z "${X}" && { MESON_FLAGS=; continue;}
  X="${X%%#*}"; X="${X#${X%%[![:space:]]*}}"
  test -n "${X}" && MESON_FLAGS="${MESON_FLAGS:+${MESON_FLAGS} }${X%${X##*[![:space:]]}}"
done

for X in '' ${DCONF}; do
  test -z "${X}" && { DCONF=; continue;}
  X="${X%%#*}"; X="${X#${X%%[![:space:]]*}}"
  test -n "${X}" && DCONF="${DCONF:+${DCONF} }${X%${X##*[![:space:]]}}"
done

for X in '' ${COPTS}; do
  test -z "${X}" && { COPTS=; continue;}
  X="${X%%#*}"; X="${X#${X%%[![:space:]]*}}"
  test -n "${X}" && COPTS="${COPTS:+${COPTS} }${X%${X##*[![:space:]]}}"
done
