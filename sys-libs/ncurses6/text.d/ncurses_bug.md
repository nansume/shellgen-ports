#######  WARNING: Variable prefix is used but was not set  #######
config.status: creating c++/Makefile
config.status: creating misc/run_tic.sh
config.status: WARNING: Variable prefix is used but was not set:
misc/run_tic.sh:47:: ${prefix:=/}
config.status: WARNING: Variable exec_prefix is used but was not set:
misc/run_tic.sh:48:: ${exec_prefix:=${prefix}}
config.status: WARNING: Variable datarootdir is used but was not set:
misc/run_tic.sh:52:: ${datarootdir:=/usr/share}
config.status: creating misc/ncurses-config
config.status: creating man/ncursesw6-config.1
####################################################



#######  Include-directory is not in a standard location  #######
** Configuration summary for NCURSES 6.3 20211021:

       extended funcs: yes
       xterm terminfo: xterm-new

        bin directory: /bin
        lib directory: /libx32
    include directory: /usr/include
        man directory: /usr/share/man
   terminfo directory: /usr/share/terminfo
 pkg-config directory: /libx32/pkgconfig

** Include-directory is not in a standard location
Configure directory: /build/ncurses-src/... ok
####################################################



#######  install libformw.so.6.3] Error 1 (ignored)  #######
cd /install/libx32 && (ln -s -f libformw.so.6.3 libformw.so.6; ln -s -f libformw.so.6 libformw.so; )
test -z "/install" && /sbin/ldconfig
make[1]: [Makefile:427: /install/libx32/libformw.so.6.3] Error 1 (ignored)
installing ./form.h in /install/usr/include
####################################################



#######  could not sym-link for compatibility  #######
"terminfo.tmp", line 8248, col 36, terminal 'dvtm-256color': limiting value of `pairs' from 0x10000 to 0x7fff
1788 entries written to /install/usr/share/terminfo
** built new /install/usr/share/terminfo
ln: /install/usr/lib/terminfo: No such file or directory
** could not sym-link /install/usr/lib/terminfo for compatibility
installing std
####################################################



#######  rm: libx32/pkgconfig/formw.pc: No such file or directory  #######
^[[1;32m +^[[1;36m /mksrc.d/44-pkg_rm.sh^[[m... ^[[1;33mrun^[[m
++ rm -r -- usr/include/curses.h usr/include/cursesapp.h usr/include/cursesf.h usr/include/cursesm.h usr/include/cursesp.h usr/include/cursesw.h usr/include/cursslk.h usr/include/eti.h usr/include/etip.h usr/include/form.h usr/include/menu.h usr/include/ncurses.h usr/include/ncurses_dll.h usr/include/panel.h usr/include/term.h usr/include/termcap.h usr/include/unctrl.h libx32/pkgconfig/formw.pc libx32/pkgconfig/menuw.pc libx32/pkgconfig/panelw.pc libx32/pkgconfig/formw.pc libx32/pkgconfig/menuw.pc libx32/pkgconfig/panelw.pc usr/share/tabset usr/share/terminfo libx32/libncurses++w.a
/mksrc.d/44-pkg_rm.sh: line 27: rm: libx32/pkgconfig/formw.pc: No such file or directory
/mksrc.d/44-pkg_rm.sh: line 27: rm: libx32/pkgconfig/menuw.pc: No such file or directory
/mksrc.d/44-pkg_rm.sh: line 27: rm: libx32/pkgconfig/panelw.pc: No such file or directory
^[[1;32m +^[[1;36m /mksrc.d/44-pkg_rm_empty.sh^[[m... ^[[1;33mrun^[[m
++ rmdir usr/share/
##########################################################