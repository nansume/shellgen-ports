#######  find: <build> No such file or directory  #######
+ nice -n 19 make --jobs=4 --load-average=4 -s V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
Building with support for profile generation:
find: 'build': No such file or directory
find: 'build': No such file or directory
find: 'build': No such file or directory
find: 'build': No such file or directory
Objects/bytearrayobject.c:2140:19: warning: cast between incompatible function types from 'PyObject * (*)(PyByteArrayObject *)' {aka 'struct _object * (*)(struct <anonymous> *)'} to 'PyObject * (*)(PyObject *, PyObject *)' {aka 'struct _object * (*)(struct _object *, struct _object *)'} [-Wcast-function-type]
 2140 |     {"__alloc__", (PyCFunction)bytearray_alloc, METH_NOARGS, alloc_doc},
##############################################################