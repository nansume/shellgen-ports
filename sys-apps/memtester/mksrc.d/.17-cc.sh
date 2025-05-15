# 2021

test "x${USER}" != 'xroot' || return 0

cc(){ gcc ${@};}

#export -f cc
