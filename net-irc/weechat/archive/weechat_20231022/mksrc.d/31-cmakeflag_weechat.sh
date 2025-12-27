# Copyright 1999-2023 Gentoo Authors, GPLv2

local EPREFIX

CMAKEFLAGS="${CMAKEFLAGS}
 -DLIBDIR=${EPREFIX}/$(get_libdir)
 -DENABLE_JAVASCRIPT=OFF
 -DENABLE_LARGEFILE=ON
 -DENABLE_NCURSES=ON
 -DENABLE_PHP=OFF
 -DENABLE_ALIAS=$(usex alias)
 -DENABLE_BUFLIST=$(usex buflist)
 -DENABLE_CHARSET=$(usex charset)
 -DENABLE_DOC=OFF
 -DENABLE_DOC_INCOMPLETE=$(usex doc)
 -DENABLE_ENCHANT=$(usex enchant)
 -DENABLE_EXEC=$(usex exec)
 -DENABLE_FIFO=$(usex fifo)
 -DENABLE_FSET=$(usex fset)
 -DENABLE_GUILE=$(usex guile)
 -DENABLE_IRC=$(usex irc)
 -DENABLE_LOGGER=$(usex logger)
 -DENABLE_LUA=$(usex lua)
 -DENABLE_MAN=$(usex man)
 -DENABLE_NLS=$(usex nls)
 -DENABLE_PERL=$(usex perl)
 -DENABLE_PYTHON=$(usex python)
 -DENABLE_RELAY=$(usex relay)
 -DENABLE_RUBY=$(usex ruby)
 -DENABLE_SCRIPT=$(usex scripts)
 -DENABLE_SCRIPTS=$(usex scripts)
 -DENABLE_SPELL=$(usex spell)
 -DENABLE_TCL=$(usex tcl)
 -DENABLE_TESTS=$(usex test)
 -DENABLE_TRIGGER=$(usex trigger)
 -DENABLE_TYPING=$(usex typing)
 -DENABLE_XFER=$(usex xfer)
 -DENABLE_ZSTD=$(usex zstd)
"
