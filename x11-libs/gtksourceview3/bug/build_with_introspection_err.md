==============================================================================================
x11-libs/gtksourceview3-3.24.11 -- BUG: no build with <introspection>
----------------------------------------------------------------------------------------------
  CCLD     libgtksourceview-core.la
  CCLD     libgtksourceview-3.0.la
  GISCAN   GtkSource-3.0.gir
Couldn't find include 'Gtk-3.0.gir' (search path: '['gir-1.0', '/usr/share/gir-1.0', '/usr/share/gir-1.0', '/usr/share/gir-1.0']')
make[4]: *** [/usr/share/gobject-introspection-1.0/Makefile.introspection:160: GtkSource-3.0.gir] Error 1
make[4]: Leaving directory '/build/gtksourceview-src/gtksourceview'
make[3]: *** [Makefile:1722: all-recursive] Error 1
==============================================================================================
