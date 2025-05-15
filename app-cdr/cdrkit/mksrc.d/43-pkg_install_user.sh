#!/bin/sh
export PN PV ED

ED=${ED:-$INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${ED}/ || return
ln -s wodim bin/cdrecord
ln -s readom bin/readcd
ln -s genisoimage bin/mkisofs
ln -s genisoimage bin/mkhybrid
ln -s icedax bin/cdda2wav

cd ${ED}/usr/share/man/man1/ || return
ln -s wodim.1 cdrecord.1
ln -s readom.1 readcd.1
ln -s genisoimage.1 mkisofs.1
ln -s genisoimage.1 mkhybrid.1
ln -s icedax.1 cdda2wav.1

printf %s\\n "Install: symlinks for bin/"
