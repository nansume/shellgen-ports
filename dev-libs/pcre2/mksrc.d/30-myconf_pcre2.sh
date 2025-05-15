# -static +static-libs +shared +nopie -patch -doc -xstub -diet +musl +stest +strip +x32

MYCONF="${MYCONF}
 --enable-pcre2-16
 --enable-pcre2-32
 --enable-pcre2grep-libz
"
