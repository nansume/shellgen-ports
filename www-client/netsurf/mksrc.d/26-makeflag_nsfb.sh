test "x${USER}" != 'xroot' || return 0

cd ${WORKDIR}/

MAKEFLAGS="${MAKEFLAGS:+${MAKEFLAGS}${NL}}TARGET=framebuffer"

# fix: Error: unpack phase - No such file or directory
ln -sf 'en/Messages' frontends/framebuffer/res/Messages
ln -sf 'en/Messages' frontends/gtk/res/Messages
ln -sf 'en/Messages' frontends/monkey/res/Messages
ln -sf 'en/Messages' frontends/riscos/appdir/Resources/de/Messages
ln -sf 'en/Messages' frontends/riscos/appdir/Resources/en/Messages
ln -sf 'en/Messages' frontends/riscos/appdir/Resources/fr/Messages
ln -sf 'en/Messages' frontends/riscos/appdir/Resources/it/Messages
ln -sf 'en/Messages' frontends/riscos/appdir/Resources/nl/Messages
