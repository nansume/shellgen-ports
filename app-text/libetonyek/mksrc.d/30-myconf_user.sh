# -static +static-libs +shared +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

# BUG: if `--with-mdds=2.1` then build - Failed

MYCONF="${MYCONF}
 --disable-werror
 --without-docs
 --disable-tests
 --with-liblangtag
 --with-mdds=1.5
 --with-tools
"
