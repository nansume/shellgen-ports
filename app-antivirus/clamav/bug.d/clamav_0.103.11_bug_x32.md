patching 01-tomsfastmath_x32.diff - nowork (in starting [x86-asm] -> [amd64-asm] required reorder)
===============================================================================================
why x86-asm instead amd64-asm?
===============================================================================================
required reorder asm: x86-asm -> amd64-asm and then patching tomsfastmath x32asm support
===============================================================================================
  CC       tomsfastmath/mul/libclamav_la-fp_mul.lo
  CC       tomsfastmath/mul/libclamav_la-fp_mul_comba.lo
  CC       tomsfastmath/mul/libclamav_la-fp_mul_2.lo
tomsfastmath/mont/fp_montgomery_reduce.c: Assembler messages:
tomsfastmath/mont/fp_montgomery_reduce.c:521: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:524: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:531: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:534: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:541: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:544: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:551: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:554: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:561: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:564: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:571: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:574: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:581: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:584: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:589: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:592: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:521: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:523: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:525: Error: operand type mismatch for `add'
tomsfastmath/mont/fp_montgomery_reduce.c:527: Error: unsupported instruction `mov'
tomsfastmath/mont/fp_montgomery_reduce.c:527: Error: no such instruction: `set %al'
  CC       tomsfastmath/mul/libclamav_la-fp_mul_2d.lo
make[4]: *** [Makefile:3946: tomsfastmath/mont/libclamav_la-fp_montgomery_reduce.lo] Error 1
make[4]: *** Waiting for unfinished jobs....
tomsfastmath/mul/fp_mul_comba.c: Assembler messages:
tomsfastmath/mul/fp_mul_comba.c:351: Error: operand type mismatch for `add'
tomsfastmath/mul/fp_mul_comba.c:352: Error: operand type mismatch for `adc'
tomsfastmath/mul/fp_mul_comba.c:353: Error: incorrect register `%r8d' used with `q' suffix
make[4]: *** [Makefile:3967: tomsfastmath/mul/libclamav_la-fp_mul_comba.lo] Error 1
===============================================================================================