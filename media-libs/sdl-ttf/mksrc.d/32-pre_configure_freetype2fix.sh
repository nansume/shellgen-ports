test "X${USER}" != 'Xroot' || return 0

sed -i \
  -e 's/freetype-config/pkgconf/' \
  -e '/$FREETYPE_CONFIG $freetypeconf_args/ s/ \(--cflags\|--libs\)/ \1 freetype2/' \
  configure
