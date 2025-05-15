# Dynamic module loading: disabled
# Static modules (include kernel?) or ipset no load module (manual load module) ?
MYCONF="${MYCONF:+${MYCONF}${NL}}--with-kmod=no"
# --with-kmod=yes - required linux-mod + build/source dir kernel(linux)
