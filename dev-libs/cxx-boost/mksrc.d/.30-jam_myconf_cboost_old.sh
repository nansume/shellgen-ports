[[ -x "${WORKDIR}/bootstrap.sh" ]] || return 0
MYCONF+=(
 abi=${ABI}
 address-model="32_64"
 architecture="x86"
 binary-format="elf"
 threading="multi"
 toolset=${CC}
 link="shared"
)