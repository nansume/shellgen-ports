MYCONF="
 --prefix=${SPREFIX}
 --libdir=${SPREFIX%/}/${LIB_DIR}
 --includedir=${INCDIR}
 $(use 'static-lib' || { use 'shared' && use_enable 'shared';} )
 $(use 'shared' || { use 'static-lib' && printf '--static';} )
"