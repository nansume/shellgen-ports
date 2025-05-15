# +static +static-libs +shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Free and Open Source spell checker designed to replace Ispell"
HOMEPAGE="http://aspell.net/"
LICENSE="LGPL-2.1"
IUSE="-nls +unicode"

# fix for musl
case $(tc-chost) in
  *-"musl"|*-"muslx32")
    use 'unicode' && append-cppflags -DNCURSES_WIDECHAR=1
  ;;
esac

#append-ldflags "-Wl,-Bstatic -l:libstdc++.a"

MYCONF="${MYCONF}
 $(use_enable 'unicode')
 $(usex 'static' --disable-pspell-compatibility)
"
