test "X${USER}" != 'Xroot' || return 0

sed -i 's/^sed /gsed /;s/ sed / gsed /g' configure