################################################################
# netsurf_3.8 - build options 'truetype': no build
################################################################
make: freetype-config: Command not found

tk_text.d build/Linux-framebuffer/frontends_framebuffer_fbtk_text.o' -MF build/Linux-framebuffer/deps/frontends_framebuffer_fbtk_text.d
 -o build/Linux-framebuffer/frontends_framebuffer_fbtk_text.o -c frontends/framebuffer/fbtk/text.c
In file included from frontends/framebuffer/font.h:62,
                 from frontends/framebuffer/fbtk/text.c:36:
frontends/framebuffer/font_freetype.h:22:10: fatal error: ft2build.h: No such file or directory
 #include <ft2build.h>


#########################
fix downgrade: =>freetype_2.9.1



####################################################################################
# netsurf_3.8 - ssl [libressl]: no build
####################################################################################
MSGSPLIT: Language: fr Filter: gtk
MSGSPLIT: Language: nl Filter: gtk
GRESORCE: frontends/gtk/res/netsurf.gresource.xml
can't write to file build/Linux-gtk3/netsurf_gresource.cmake: *** [frontends/gtk/Makefile:117: build/Linux-gtk3/netsurf_gresource.c] Error 1

fix build: build options: [openssl]



# make: execvp: freetype-config: Permission denied
# frontends/framebuffer/font_freetype.h:22:10:
#  fatal error: ft2build.h: No such file or directory
#  #include <ft2build.h>
cp -nl usr/include/freetype2/ft2build.h <WORKDIR>/include/ft2build.h