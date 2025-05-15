# http://midnight-commander.org/wiki/doc/buildAndInstall/confOptions

MYCONF="
 --prefix=${SPREFIX}
 --bindir=${SPREFIX%/}/bin
 --sbindir=${SPREFIX%/}/sbin
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 --libexecdir=${DPREFIX}/libexec
 --datarootdir=${DPREFIX}/share
 --host=${CHOST}
 --build=${CHOST}
 --with-homedir=$(usex 'xdg' XDG yes)
 --with-pcre=$(usex 'pcre' yes no)
 $(use_enable 'shared' mclib)
 $(use_enable 'static-libs' static)
 $(use_enable 'nls')
 $(use_enable 'rpath')
 --with-screen=$(usex 'unicode' ncursesw ncurses)
 $(use_with 'x')
 $(use_enable 'spell' aspell)
 $(use_enable 'subshell' background)
 $(use_enable 'charset')
 $(use_enable 'charset')
 $(use_with 'diff' diff-viewer)
 $(use_with 'edit' internal-edit)
 $(use_with 'gpm' gpm-mouse)
 --with-subshell=$(usex 'subshell' yes no)
 $(use_enable 'tests')
 --with-search-engine=$(usex 'glib' glib pcre)
 $(use_enable 'vfs')
 $(use_enable 'cpio' vfs-cpio)
 $(use_enable 'tar' vfs-tar)
 $(use_enable 'vfs' vfs-sfs)
 $(use_enable 'vfs' vfs-extfs)
 --disable-vfs-fish
 $(use_enable 'smb' vfs-smb)
 $(use_enable 'ftp' vfs-ftp)
 $(use_enable 'sftp' vfs-sftp)
"