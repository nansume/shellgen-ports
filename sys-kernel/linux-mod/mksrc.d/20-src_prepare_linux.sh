# 2021-2023

local RMLIST; local X

test -d "${WORKDIR}" || return 0
cd ${WORKDIR}/

{ test "x${USER}" != 'xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

KDATE=$(date '+%Y%m%d')

# Expert Mode depend Kernel debugging remove
# <<menuconfig EXPERT>> - search string
# <<select DEBUG_KERNEL>> - rm string
sed -i '/^\tselect\ DEBUG_KERNEL$/d' init/Kconfig
sed -i '/^\tselect\ CRYPTO_LZO$/d' drivers/block/zram/Kconfig
sed -i '/^\tselect\ CPU_FREQ_GOV_PERFORMANCE$/d' drivers/cpufreq/Kconfig
#mapfile -tn 50 -d "${IFS} DUMPF < drivers/block/zram/Kconfig
#printf %s%b ${DUMPF[*]#[[:cntrl:]]select DEBUG_KERNEL}" \n > init/Kconfig

#if [[ ${ABI} == x86 ]]; then
#  sed -i /HOSTCFLAGS/ s/-O2/-O3 -msse/" Makefile
#  sed -i /HOSTCXXFLAGS/ s/-O2/-O3 -msse/" Makefile
#else
#  sed -i /HOSTCFLAGS/ s/-O2/-O3 -msse3/" Makefile
#  sed -i /HOSTCXXFLAGS/ s/-O2/-O3 -msse3/" Makefile
#fi

RMLIST=
for X in "${PDIR}/lst.d/18"[_-]"rmsrc_"*".lst"; do
  test -e "${X}" || continue
  while IFS= read -r X; do
    X=${X%%#*}
    X="${X%${X##*[![:space:]]}}"
    { test -n "${X}" && test -e "${X}" ;} &&
    RMLIST="${RMLIST:+${RMLIST} }${X#${X%%[![:space:]]*}}"
  done < ${X}
done

test -n "${RMLIST}" || return 0
set -o 'xtrace'
rm -r -- ${RMLIST}
{ set +o 'xtrace';} >/dev/null 2>&1
