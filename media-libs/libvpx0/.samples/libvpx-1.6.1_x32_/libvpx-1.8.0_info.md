86df18c694e1c06cc8f83d2d816e9270747a0ce6abe316e93a4f4095689373f6  libvpx-1.8.0.tar.gz

https://github.com/webmproject/libvpx/archive/v1.8.0/libvpx-1.8.0.tar.gz

build deps:
 cat-utils
 diffutils
 od-utils
 #nasm
 yasm

removelist.lst:
 build.deps/cat
 build.deps/diff
 build.deps/od
 mksrc.d/27-pre_myconf.sh