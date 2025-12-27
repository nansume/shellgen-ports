#qfiledialog bug fix muslx32 overlay added fix from upstream
#case $(tc-chost) in
#  *-"muslx32")
#    patch -p1 -E < "${FILESDIR}/qt464-iconv.patch"
#  ;;
#esac

MYCONF="\
 -prefix ''
 -bindir ${EPREFIX%/}/bin
 -sysconfdir ${EPREFIX%/}/etc
 -libdir ${EPREFIX%/}/$(get_libdir)
 -headerdir ${INCDIR}
 -datadir ${DPREFIX}/share
 -docdir ${DPREFIX}/share/doc
 -arch $(arch)
 -opensource
 -confirm-license
 -release
 -no-accessibility
 -no-xmlpatterns
 -no-multimedia
 -no-audio-backend
 -no-phonon
 -no-phonon-backend
 -no-svg
 -no-gui
 -no-webkit
 -no-script
 -no-scripttools
 -no-declarative
 -qt-zlib
 -no-gif
 -no-libtiff
 -no-libpng
 -no-libmng
 -no-libjpeg
 -no-cups
 -no-dbus
 -no-gtkstyle
 -no-nas-sound
 -no-opengl
 -no-openvg
 -no-sm
 -no-xshape
 -no-xvideo
 -no-xsync
 -no-xinerama
 -no-xcursor
 -no-xfixes
 -no-xrandr
 -no-xrender
 -no-mitshm
 -no-fontconfig
 -no-freetype
 -no-xinput
 -no-xkb
 -no-mmx
 -no-3dnow
 -no-sse3
 -no-ssse3
 -no-sse4.1
 -no-sse4.2
 -no-avx
 -nomake demos
 -nomake examples
 -nomake docs
 $(usex 'glib' -glib -no-glib)
 $(usex 'iconv' -iconv -no-iconv)
 $(usex 'icu' -icu)
 $(usex 'ssl' -openssl-linked -no-openssl)
 $(usex 'qt3support' -qt3support -no-qt3support)
 $(usex 'shared' -shared )
 $(usex 'static-libs' -static)
 $(usex 'rpath' -rpath -no-rpath)
"
