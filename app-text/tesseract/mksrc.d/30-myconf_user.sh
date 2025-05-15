# +static +static-libs -shared -upx -patch -doc -xstub -diet +musl +stest +strip +x32

DESCRIPTION="An OCR Engine, originally developed at HP, now open source"
HOMEPAGE="https://github.com/tesseract-ocr"
LICENSE="Apache-2.0"
IUSE="-doc +float32 +jpeg -opencl +openmp +png +static-libs +tiff -training +webp"

MYCONF="${MYCONF}
 --disable-graphics
 $(use_enable 'float32')
 $(use_enable 'opencl')
 $(use_enable 'openmp')
 $(use_enable 'doc')
"
