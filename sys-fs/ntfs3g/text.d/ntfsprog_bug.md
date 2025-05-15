# error fix: PV="3g.ntfsprogs-2017.3.23" --> PV="2017.3.23"
PV=${PV#*-}


# future fix - configure: WARNING
checking uuid/uuid.h presence... no
checking for uuid/uuid.h... no
configure: WARNING: ntfsprogs DCE compliant UUID generation code requires the uuid library.
checking hd.h usability... no
checking hd.h presence... no
checking for hd.h... no
configure: WARNING: ntfsprogs Windows compliant geometry code requires the hd library.
checking for ANSI C header files... (cached) yes
checking whether sys/types.h defines makedev... no
checking sys/mkdev.h usability... no
checking sys/mkdev.h presence... no
checking for sys/mkdev.h... no
checking sys/sysmacros.h usability... yes

# required fix?
checking for hd.h... no

# required fix?
checking whether sys/types.h defines makedev... no