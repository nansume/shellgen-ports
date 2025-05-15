#!/bin/sh
# -static -static-libs -shared -upx -patch -doc -xstub -diet -musl -stest -strip +noarch

DESCRIPTION="Fast integer versions of trained models for app-text/tesseract"
HOMEPAGE="https://github.com/tesseract-ocr/tessdata_fast"
LICENSE="Apache-2.0"
PV="4.1.0"
XPN=${PN%-*}
FILESDIR=${DISTSOURCE}
BUILD_DIR=${WORKDIR}
ED=${INSTALL_DIR}

test "X${USER}" != 'Xroot' || return 0

cd ${BUILD_DIR}/ || return

mkdir -pm 0755 "${ED}"/usr/share/${XPN}/

for F in ${FILESDIR}/*.traineddata-*-${PV}; do
  F=${F##*/}
  cp -n -L "${FILESDIR}/${F}" "${ED}/usr/share/${XPN}/${F%%-*}" || die
done
printf %s\\n "Install: *.traineddata usr/share/${XPN}/"
