####  8deb38c8de41fb5558640cdd4b9b161c38de92c077b3e506f74c34f93214f469  simutrans-src-123-0-1.zip

[ftp://ftp.vectranet.pl/gentoo/distfiles/simutrans-src-123-0-1.zip]

build bdepend:
=================
uname
unzip
libpng
libbz2
#pkg-config
sdl2
#sdl
#sdl-mixer
git
=================


#########################################################################
# simutrans_0.120.2.2 - error: binding reference of type 'koord&'
#########################################################################
bauer/../tpl/../macros.h:7:42: warning: this use of "defined" may not be portable [-Wexpansion-to-defined]
 #if !defined __GNUC__ || GCC_ATLEAST(3, 0)
                                          ^
In file included from bauer/../simcity.h:16,
                 from bauer/fabrikbauer.cc:17:
bauer/../tpl/sparse_tpl.h: In member function 'koord& sparse_tpl<T>::get_size() const':
bauer/../tpl/sparse_tpl.h:60:11: error: binding reference of type 'koord&' to 'const koord' discards qualifiers
    return size;
           ^~~~
make: *** [common.mk:51: build/default/bauer/fabrikbauer.o] Error 1
=========================================================================


#########################################################################
# https://stackoverflow.com/
#  questions/47751900/error-binding-to-reference-discard-qualfier
[[ -f bauer/fabrikbauer.cc && ! ${FILE-} ]] || return

 #bauer/fabrikbauer.cc \
 #dataobj/koord.h \
 #dataobj/koord3d.h \
 #dataobj/ribi.cc \
 #dataobj/ribi.h \
 #tpl/sparse_tpl.h
for FILE in **; {
  case $FILE in
    *.cc|*.h)
      #sed -i 's|koord&|koord \&|' $FILE
      sed -i 's|\([^ &]\{5,12\}\)&|\1 \&|' $FILE
                  ;;
               esac
            }

         #   CXXFLAGS+=' -std=gnu++14'
#########################################################################



########   simutrans-src-123-0-1   ##########
#####################################################################################
checking for library containing upnpDiscover... no
checking for library containing FT_Init_FreeType... no
checking for library containing new_fluid_settings... no
Linux
configure: WARNING: Using SDL2 backend!
./configure: line 5531: svn: command not found
checking size of void*... 4
configure: creating ./config.status
config.status: creating config.default
Configure directory: /build/simutrans-src/... ok
 + /mksrc.d/36-pkg_compile.sh... run
 + nice -n 19 make --jobs=4 --load-average=4 -s V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
fatal: Not a git repository (or any of the parent directories): .git
Git hash is 0x
===> HOSTCXX sys/clipboard_s2.cc
===> HOSTCXX bauer/brueckenbauer.cc
===> HOSTCXX bauer/fabrikbauer.cc
===> HOSTCXX bauer/goods_manager.cc


===> HOSTCXX boden/wege/weg.cc
===> HOSTCXX dataobj/crossing_logic.cc
===> HOSTCXX dataobj/environment.cc
In file included from dataobj/../simversion.h:12,
                 from dataobj/environment.cc:10:
dataobj/../revision.h:1:1: error: stray '\' in program
    1 | \#define REVISION
      | ^
dataobj/../revision.h:1:2: error: stray '#' in program
    1 | \#define REVISION
      |  ^
dataobj/../revision.h:1:3: error: 'define' does not name a type
    1 | \#define REVISION
      |   ^~~~~~
In file included from dataobj/../sys/simsys.h:14,
                 from dataobj/environment.cc:13:
/usr/include/zlib.h:1420:9: error: 'z_size_t' does not name a type; did you mean 'ssize_t'?
 1420 | ZEXTERN z_size_t ZEXPORT gzfread OF((voidp buf, z_size_t size, z_size_t nitems,
      |         ^~~~~~~~
      |         ssize_t
/usr/include/zlib.h:1454:9: error: 'z_size_t' does not name a type; did you mean 'ssize_t'?
 1454 | ZEXTERN z_size_t ZEXPORT gzfwrite OF((voidpc buf, z_size_t size,
      |         ^~~~~~~~
      |         ssize_t
In file included from /usr/include/zlib.h:34,
                 from dataobj/../sys/simsys.h:14,
                 from dataobj/environment.cc:13:
/usr/include/zlib.h:1707:33: error: 'z_size_t' has not been declared
 1707 | ZEXTERN uLong ZEXPORT adler32_z OF((uLong adler, const Bytef *buf,
      |                                 ^~
/usr/include/zlib.h:1742:31: error: 'z_size_t' has not been declared
 1742 | ZEXTERN uLong ZEXPORT crc32_z OF((uLong adler, const Bytef *buf,
      |                               ^~
make: *** [common.mk:50: build/default/dataobj/environment.o] Error 1
make: *** Waiting for unfinished jobs....
 + /mksrc.d/20-gen_variables.sh... run
#####################################################################################


rmlist:
===========================================================
<DPREFIX>/share/pixmaps
<DPREFIX>/share/<PN>/font/Prop-Latin1.bdf
<DPREFIX>/share/<PN>/font/Prop-Latin2.bdf
<DPREFIX>/share/<PN>/font/cyr.bdf
<DPREFIX>/share/<PN>/font/m+10r.bdf
<DPREFIX>/share/<PN>/font/prop-latin2.fnt
<DPREFIX>/share/<PN>/font/ro_font.fnt
<DPREFIX>/share/<PN>/music
<DPREFIX>/share/<PN>/pak/scenario/anthill/de.tab
<DPREFIX>/share/<PN>/pak/scenario/millionaire/de.tab
<DPREFIX>/share/<PN>/pak/scenario/pharmacy-max/de.tab
<DPREFIX>/share/<PN>/pak/scenario/pharmacy-max/de
<DPREFIX>/share/<PN>/pak/sound
<DPREFIX>/share/<PN>/pak/text/be.tab
<DPREFIX>/share/<PN>/pak/text/ca.tab
<DPREFIX>/share/<PN>/pak/text/ce.tab
<DPREFIX>/share/<PN>/pak/text/citylist_cz.txt
<DPREFIX>/share/<PN>/pak/text/citylist_de.txt
<DPREFIX>/share/<PN>/pak/text/citylist_de_at.txt
<DPREFIX>/share/<PN>/pak/text/citylist_de_ch.txt
<DPREFIX>/share/<PN>/pak/text/citylist_dk.txt
<DPREFIX>/share/<PN>/pak/text/citylist_en_au.txt
<DPREFIX>/share/<PN>/pak/text/citylist_en_gb.txt
<DPREFIX>/share/<PN>/pak/text/citylist_en_nz.txt
<DPREFIX>/share/<PN>/pak/text/citylist_es.txt
<DPREFIX>/share/<PN>/pak/text/citylist_fi.txt
<DPREFIX>/share/<PN>/pak/text/citylist_fr.txt
<DPREFIX>/share/<PN>/pak/text/citylist_hu.txt
<DPREFIX>/share/<PN>/pak/text/citylist_it.txt
<DPREFIX>/share/<PN>/pak/text/citylist_ja.txt
<DPREFIX>/share/<PN>/pak/text/citylist_lt.txt
<DPREFIX>/share/<PN>/pak/text/citylist_lt.txt
<DPREFIX>/share/<PN>/pak/text/citylist_nl.txt
<DPREFIX>/share/<PN>/pak/text/citylist_pl.txt
<DPREFIX>/share/<PN>/pak/text/citylist_pt.txt
<DPREFIX>/share/<PN>/pak/text/citylist_ro.txt
<DPREFIX>/share/<PN>/pak/text/citylist_ru.txt
<DPREFIX>/share/<PN>/pak/text/citylist_sk.txt
<DPREFIX>/share/<PN>/pak/text/citylist_zh.txt
<DPREFIX>/share/<PN>/pak/text/cn.tab
<DPREFIX>/share/<PN>/pak/text/cz.tab
<DPREFIX>/share/<PN>/pak/text/de.tab
<DPREFIX>/share/<PN>/pak/text/dk.tab
<DPREFIX>/share/<PN>/pak/text/es.tab
<DPREFIX>/share/<PN>/pak/text/et.tab
<DPREFIX>/share/<PN>/pak/text/fi.tab
<DPREFIX>/share/<PN>/pak/text/fr.tab
<DPREFIX>/share/<PN>/pak/text/frp.tab
<DPREFIX>/share/<PN>/pak/text/gr.tab
<DPREFIX>/share/<PN>/pak/text/hr.tab
<DPREFIX>/share/<PN>/pak/text/hu.tab
<DPREFIX>/share/<PN>/pak/text/id.tab
<DPREFIX>/share/<PN>/pak/text/it.tab
<DPREFIX>/share/<PN>/pak/text/ja.tab
<DPREFIX>/share/<PN>/pak/text/ko.tab
<DPREFIX>/share/<PN>/pak/text/lt.tab
<DPREFIX>/share/<PN>/pak/text/nl.tab
<DPREFIX>/share/<PN>/pak/text/no.tab
<DPREFIX>/share/<PN>/pak/text/pl.tab
<DPREFIX>/share/<PN>/pak/text/pt.tab
<DPREFIX>/share/<PN>/pak/text/ro.tab
<DPREFIX>/share/<PN>/pak/text/ru.tab
<DPREFIX>/share/<PN>/pak/text/sk.tab
<DPREFIX>/share/<PN>/pak/text/sv.tab
<DPREFIX>/share/<PN>/pak/text/uk.tab
<DPREFIX>/share/<PN>/pak/text/zh.tab
<DPREFIX>/share/<PN>/text/be.tab
<DPREFIX>/share/<PN>/text/bg.tab
<DPREFIX>/share/<PN>/text/ca.tab
<DPREFIX>/share/<PN>/text/ce.tab
<DPREFIX>/share/<PN>/text/cn.tab
<DPREFIX>/share/<PN>/text/cn
<DPREFIX>/share/<PN>/text/cz.tab
<DPREFIX>/share/<PN>/text/cz
<DPREFIX>/share/<PN>/text/de.tab
<DPREFIX>/share/<PN>/text/de
<DPREFIX>/share/<PN>/text/dk.tab
<DPREFIX>/share/<PN>/text/dk
<DPREFIX>/share/<PN>/text/es.tab
<DPREFIX>/share/<PN>/text/es
<DPREFIX>/share/<PN>/text/et.tab
<DPREFIX>/share/<PN>/text/fi.tab
<DPREFIX>/share/<PN>/text/fi
<DPREFIX>/share/<PN>/text/fr.tab
<DPREFIX>/share/<PN>/text/fr
<DPREFIX>/share/<PN>/text/frp.tab
<DPREFIX>/share/<PN>/text/gr.tab
<DPREFIX>/share/<PN>/text/hr.tab
<DPREFIX>/share/<PN>/text/hr
<DPREFIX>/share/<PN>/text/hu.tab
<DPREFIX>/share/<PN>/text/hu
<DPREFIX>/share/<PN>/text/id.tab
<DPREFIX>/share/<PN>/text/id
<DPREFIX>/share/<PN>/text/it.tab
<DPREFIX>/share/<PN>/text/it
<DPREFIX>/share/<PN>/text/ja.tab
<DPREFIX>/share/<PN>/text/ja
<DPREFIX>/share/<PN>/text/ko.tab
<DPREFIX>/share/<PN>/text/ko
<DPREFIX>/share/<PN>/text/lt.tab
<DPREFIX>/share/<PN>/text/nl.tab
<DPREFIX>/share/<PN>/text/nl
<DPREFIX>/share/<PN>/text/no.tab
<DPREFIX>/share/<PN>/text/pl.tab
<DPREFIX>/share/<PN>/text/pl
<DPREFIX>/share/<PN>/text/pt.tab
<DPREFIX>/share/<PN>/text/pt
<DPREFIX>/share/<PN>/text/ro.tab
<DPREFIX>/share/<PN>/text/ro
<DPREFIX>/share/<PN>/text/ru.tab
<DPREFIX>/share/<PN>/text/ru
<DPREFIX>/share/<PN>/text/sk.tab
<DPREFIX>/share/<PN>/text/sk
<DPREFIX>/share/<PN>/text/sq.tab
<DPREFIX>/share/<PN>/text/sv.tab
<DPREFIX>/share/<PN>/text/sv
<DPREFIX>/share/<PN>/text/th.tab
<DPREFIX>/share/<PN>/text/tr.tab
<DPREFIX>/share/<PN>/text/tr
<DPREFIX>/share/<PN>/text/uk.tab
<DPREFIX>/share/<PN>/text/uk
<DPREFIX>/share/<PN>/text/zh.tab
<DPREFIX>/share/<PN>/text/zh
===========================================================