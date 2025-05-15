# support x32 (disable-sse)
# Gentoo Forums :: View topic - libvpx can't compile with CPU_FLAGS_X86 mmx or sse2
#  https://forums.gentoo.org/viewtopic-t-1062094-start-0.html

########################################
#         | MMX  | SSE  | SSE2 | SSE3  #
# --------+------+------+------+------ #
# ~1.6.1: |  X   |  O   |  X   |  O    #
# ~1.6.0: |  O   |  O   |  X   |  O    #
# ~1.5.0: |  X   |  O   |  X   |  O    #
########################################

[[ ${ABI} == 'x32' ]] || return

MYCONF+=( --disable-sse )