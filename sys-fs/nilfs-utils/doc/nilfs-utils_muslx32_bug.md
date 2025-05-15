sys-fs/nilfs-utils-2.2.2 - 2.2.11 - BUG: nilfs_cleanerd, nilfs-clean to runtime. (muslx32)
===============================================================================================================
nilfs_cleanerd /dev/sdxX - Failed runtime
nilfs-clean --status /dev/sdxX
-----------------------------------------------------
Error: cannot create receive queue: Invalid argument.
-----------------------------------------------------
Runtime bug only <muslx32>
-----------------------------------------------------
x86_64-linux-muslx32 - BUG
x86_64-linux-gnux32 - WORK
x86_64-linux-musl - WORK
and etc ... - WORK
===============================================================================================================

---------------------------------------------
FIX: static build <x86_64-linux-musl> (amd64)
---------------------------------------------