#!/bin/sh
# Copyright (C) 2021-2022 Artjom Slepnjov, Shellgen
# License GPLv3: GNU GPL version 3 only
# http://www.gnu.org/licenses/gpl-3.0.html
# mc version compatible: 4.8.23 - 4.8.26

local NL="$(printf '\n\t')"; NL=${NL%?}; local IFS=${NL}; local DUMPF; local F; local X

test -d "${INSTALL_DIR}" || return 0
cd "${INSTALL_DIR}/"

{ test "X${USER}" != 'Xroot' || test "${USE_BUILD_ROOT:=0}" -ne '0' ;} || return 0

F="etc/${PN}/${PN}.ext"; test -f "${F}" &&

sed -i \
  -e 's@shell/.cpio.xz$@regex/\.c(pio\.xz|xz)@' \
  -e 's@shell/.cpio.zst$@regex/\.c(pio\.zst|zst)@' \
  -e 's@:vi}@:nano}@' \
  -e 's@:more}$@:less}@' \
  -e 's@type/^JPEG$@shell/i/.jpg@' \
  -e 's@type/^PNG$@shell/i/.png@' \
  -e 's@sound.sh@media.sh@' \
  -e 's@image.sh@media.sh@' \
  -e 's@video.sh@media.sh@' \
  -e 's@mov|qt@ogm|mov|qt@' \
  -e 's@default/\*$@default/.text$@' \
  -e 's@%Open=@Open=editor@' \
  -e 's@%View=@View=editor@' \
  -e 's@Open=/@Open=exec @' ${F}


F="etc/${PN}/filehighlight.ini"; test -f "${F}" &&
#sed -i /extensions=7z/ s|rar|cxz|' /etc/${PN}/filehighlight.ini
# s|type/\^JPEG|shell/i/.jpg| s/\(sound\|image\|video\).sh/media.sh/
# /(mov|qt)/ s/mov|qt/ogm|mov|qt/ s|View=$|View=editor|
sed -i \
  -e 's/;rar;/;cxz;rar;/' \
  -e 's/;sl;/;ipxe;/' \
  -e 's/;sas;/;nft;/' \
  -e 's/;prg;/;sed;/' \
  -e 's/;xq/;env;ebuild/' \
  -e 's/extensions=chm;/extensions=lst;/' \
  -e 's/;docx;/;conf;/' \
  -e 's/;pptx;/;arg;/' \
  -e 's/;Z;/;/' \
  -e 's/;ace;/;/' \
  -e 's/;arc;/;/' \
  -e 's/;arj;/;/' \
  -e 's/;ark;/;/' \
  -e 's/;cab;/;/' \
  -e 's/;zoo;/;/' \
  -e 's/;ctl;/;/' \
  -e 's/;diz;/;/' \
  -e 's/;doc;/;/' \
  -e 's/;docm;/;/' \
  -e 's/;htm;/;/' \
  -e 's/;lsm;/;/' \
  -e 's/;ppt;/;/' \
  -e 's/;pptm;/;/' \
  -e 's/;rtf;/;/' \
  -e 's/;txt;/;/' \
  -e 's/;xls;/;/' \
  -e 's/;xlsm;/;/' \
  -e 's/;xlsx;/;/' \
  -e 's/;xml;/;/' \
  -e 's/;go;/;/' \
  -e 's/;wmf;/;/' \
  -e 's/;mdb;mdn;mdx;msql;mssql;/;/' ${F}


F="${DPREFIX#/}/libexec/${PN}/ext.d/archive.sh"; test -f "${F}" &&

sed -i -e 's/cpio.xz)/cxz|&/' -e 's/cpio.zst)/czst|&/' ${F}
