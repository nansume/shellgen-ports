####  042937f483603f0c3d1dec11e8f0045e8c27f19eee46ea64d81a3cdf01e51233  mpv-0.14.0.tar.gz
[ftp://localhost/v0.14.0.tar.gz]  -->  [mpv-0.14.0.tar.gz]

build depend:
=======================
expat
alsa-lib
alsa-utils
fontconfig
freetype
liberation-fonts
libass
#fribidi
harfbuzz
libdrm
ffmpeg
=======================
###################################################################################


###################################################################################
####  mpv-0.27.2

build depend flag:
============================================================
gst-plugins-vaapi: -opengl
mpv: -vulkan -lcms -uchardet
mpv: -cdda -egl -iconv -jpeg -lua -luajit -opengl -sdl -zlib
#libva* -video_cards_nouveau -opengl -egl

# requred: ffmpeg [encode]
<=mpv-0.27.2: -encode python3

libdrm: libkms
mpv: drm
mpv: python3 alsa

freetype: infinality
mpv: -X -xv opengl

# ass
mpv: libass
libass: harfbuzz fontconfig
harfbuzz: truetype fontconfig -icu
============================================================

###################################################################################


###################################################################################
mpv-0.27.2 - mpv-0.29.1-r1

=========================
# required - >=mpv-0.29.1
ffmpeg: encode
=========================

printf $(< $HOME/.lst/mediainfo)
 [ffmpeg] Invalid return value 0 for stream protocol
###################################################################################


==============================================================
# 2021-2022 Artjom Slepnjov, Shellgen


# makeflag mpv
===============================
((UID)) || return 0

declare F GLOBIGNORE

cd ${WORKDIR}/
shopt -s 'globstar' 'nullglob' 'extglob'

GLOBIGNORE="!(+(*/old-)+(makefile|configure))"

for F in **; {
  mv -vn "${F}" ${F/old-}
  F=${F/old-}
}
MAKEFLAGS+=" -f ${F}"

shopt -u 'globstar' 'nullglob' 'extglob'
===============================


# myconf mpv
===============================
MYCONF+=(
 --disable-dvb
 --disable-tv
 --disable-tv-v4l2
 --disable-ossaudio
 --disable-jpeg
 --disable-libass
 --disable-libavresample
 --disable-encoding
)
===============================


# rm conf
===============================
MYCONF=(${MYCONF[@]%--build=*})
MYCONF=(${MYCONF[@]%--datarootdir=*})
MYCONF=(${MYCONF[@]%--host=*})
MYCONF=(${MYCONF[@]%--includedir=*})
MYCONF=(${MYCONF[@]%--libdir=*})
MYCONF=(${MYCONF[@]%--libexecdir=*})
MYCONF=(${MYCONF[@]/--enable-shared})
===============================


# pkg configure mpv
===============================
((UID)) || return 0

cd "${WORKDIR}/"

if [[ -x 'TOOLS/configure' ]]; then
  ./TOOLS/configure ${MYCONF[@]}
fi
===============================

==============================================================