# USE= -static +static-libs +shared +nopie +patch -doc +xstub -diet +musl +stest +strip +x32

MYCONF="${MYCONF}
 --without-doxygen
 --disable-swig
 --disable-werror
"
