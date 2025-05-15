#######  x32-bug: build with bundled <libffi> incompatible asm  #######
gcc -fPIC -fno-strict-aliasing -mx32 -msse2 -O2 -fno-stack-protector -g0 -march=x86-64 -DNDEBUG -g -fwrapv -O3 -Wall -Wstrict-prototypes -Ibuild/temp.linux-x86_64-2.7/libffi/include -Ibuild/temp.linux-x86_64-2.7/libffi -I/build/Python-2.7.14/Modules/_ctypes/libffi/src -I/usr/include -I. -IInclude -I./Include -I/build/Python-2.7.14/Include -I/build/Python-2.7.14 -c /build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S -o build/temp.linux-x86_64-2.7/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.o -Wall -fexceptions
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S: Assembler messages:
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:523: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:534: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:535: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:607: Error: operand type mismatch for `jmp'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:681: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:694: Error: operand type mismatch for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:707: Error: operand type mismatch for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:708: Error: operand type mismatch for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:723: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:778: Error: operand type mismatch for `jmp'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:833: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:845: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:886: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:890: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:933: Error: operand type mismatch for `jmp'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:991: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:992: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:1009: Error: invalid instruction suffix for `push'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:1061: Error: operand type mismatch for `jmp'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:1119: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:1120: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:1121: Error: invalid instruction suffix for `pop'
/build/Python-2.7.14/Modules/_ctypes/libffi/src/x86/win32.S:1132: Error: operand type mismatch for `jmp'
##############################################################

Failed to build these modules:
_ctypes