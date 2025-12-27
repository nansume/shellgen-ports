###################################################
# 925811 - qt4-x11: ftbfs with GCC-9 - Debian Bug report logs
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=925811
https://salsa.debian.org/qt-kde-team/qt/qt4-x11/-/archive/0d4a3dd61ccb156dee556c214dbe91c04d44a717/
 qt4-x11-0d4a3dd61ccb156dee556c214dbe91c04d44a717.tar.bz2

avx auto-detection... ()
avx enabled.
ipc_sysv auto-detection... ()
ipc_sysv enabled.
DB2 auto-detection... ()
qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/config.tests/unix/db2/db2.cpp:42:10: fatal error: sqlcli.h: No such file or directory
   42 | #include <sqlcli.h>
      |          ^~~~~~~~~~
compilation terminated.
gmake: *** [Makefile:187: db2.o] Error 1
DB2 disabled.
OCI auto-detection... ()
qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/config.tests/unix/oci/oci.cpp:42:10: fatal error: oci.h: No such file or directory
   42 | #include <oci.h>
      |          ^~~~~~~
compilation terminated.
gmake: *** [Makefile:187: oci.o] Error 1
OCI disabled.
unknown SQL driver: sqlite_symbian
unknown SQL driver: symsql
TDS auto-detection... ()
qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/config.tests/unix/tds/tds.cpp:42:10: fatal error: sybfront.h: No such file or directory
   42 | #include <sybfront.h>
      |          ^~~~~~~~~~~~
compilation terminated.
gmake: *** [Makefile:187: tds.o] Error 1
TDS disabled.
Cups auto-detection... ()
Cups enabled.
POSIX iconv auto-detection... ()
POSIX iconv enabled.
D-Bus auto-detection... ()


Debug .................. no
Qt 3 compatibility ..... no
QtDBus module .......... yes (run-time)
QtConcurrent code ...... yes
QtGui module ........... yes
QtScript module ........ yes
QtScriptTools module ... yes
QtXmlPatterns module ... no
Phonon module .......... no
Multimedia module ...... auto
SVG module ............. no
WebKit module .......... no
JavaScriptCore JIT ..... To be decided by JavaScriptCore
Declarative module ..... yes
Declarative debugging ...yes
Support for S60 ........ no
Symbian DEF files ...... no
STL support ............ yes
PCH support ............ no
MMX/3DNOW/SSE/SSE2/SSE3. yes/yes/yes/yes/yes
SSSE3/SSE4.1/SSE4.2..... yes/yes/yes
AVX..................... yes
Graphics System ........ default
IPv6 support ........... yes
IPv6 ifname support .... yes
getaddrinfo support .... yes
getifaddrs support ..... yes
Accessibility .......... no
NIS support ............ no
CUPS support ........... yes
Iconv support .......... yes
Glib support ........... yes
GStreamer support ...... no
PulseAudio support ..... no
Large File support ..... yes
GIF support ............ plugin
TIFF support ........... plugin (system)
JPEG support ........... plugin (system)
PNG support ............ yes (system)
MNG support ............ no
zlib support ........... system
Session management ..... yes
OpenGL support ......... no
OpenVG support ......... no
NAS sound support ...... no
XShape support ......... yes
XVideo support ......... yes
XSync support .......... yes
Xinerama support ....... no
Xcursor support ........ yes
Xfixes support ......... yes
Xrandr support ......... yes
Xrender support ........ yes
Xi support ............. yes
MIT-SHM support ........ yes
FontConfig support ..... yes
XKB Support ............ yes
immodule support ....... yes
GTK theme support ...... no
OpenSSL support ........ yes (run-time)
Alsa support ........... no
ICD support ............ no
libICU support ......... yes
Use system proxies ..... no

In file included from ../../include/QtGui/private/qtextengine_p.h:1,
                 from ../../include/QtGui/private/../../../../qt-everywhere-opensource-src-4.8.7/src/gui/text/qfontengine_p.h:60,
                 from ../../include/QtGui/private/qfontengine_p.h:1,
                 from ../../include/QtGui/private/../../../../qt-everywhere-opensource-src-4.8.7/src/gui/painting/qpdf_p.h:59,
                 from ../../include/QtGui/private/qpdf_p.h:1,
                 from qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/src/gui/dialogs/qpagesetupdialog_unix.cpp:59:
../../include/QtGui/private/../../../../qt-everywhere-opensource-src-4.8.7/src/gui/text/qtextengine_p.h:256:80: warning: 'void* memset(void*, int, size_t)' clearing an object of non-trivial type 'struct QGlyphJustification'; use assignment or value-initialization instead [-Wclass-memaccess]
  256 |             memset(justifications + first, 0, num * sizeof(QGlyphJustification));
      |                                                                                ^
../../include/QtGui/private/../../../../qt-everywhere-opensource-src-4.8.7/src/gui/text/qtextengine_p.h:141:8: note: 'struct QGlyphJustification' declared here
  141 | struct QGlyphJustification
      |        ^~~~~~~~~~~~~~~~~~~
qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/src/gui/dialogs/qpagesetupdialog_unix.cpp: In constructor 'QPageSetupWidget::QPageSetupWidget(QWidget*)':
qtgui-4.8.7/work/qt-everywhere-opensource-src-4.8.7/src/gui/dialogs/qpagesetupdialog_unix.cpp:276:12: error: 'class Ui::QPageSetupWidget' has no member named 'topMargin'
  276 |     widget.topMargin->setSuffix(suffix);
      |            ^~~~~~~~~
qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/src/gui/dialogs/qpagesetupdialog_unix.cpp:277:12: error: 'class Ui::QPageSetupWidget' has no member named 'bottomMargin'
  277 |     widget.bottomMargin->setSuffix(suffix);
      |            ^~~~~~~~~~~~
qtgui-4.8.7-src/qt-everywhere-opensource-src-4.8.7/src/gui/dialogs/qpagesetupdialog_unix.cpp:278:12: error: 'class Ui::QPageSetupWidget' has no member named 'leftMargin'
  278 |     widget.leftMargin->setSuffix(suffix);