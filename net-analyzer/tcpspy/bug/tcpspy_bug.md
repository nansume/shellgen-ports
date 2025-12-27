==================================================================================================================
net-analyzer/tcpspy-1.7d - error: unknown type name <u_int16_t> <u_int32_t>
==================================================================================================================
gcc -mx32 -msse2 -O2 -fno-stack-protector -no-pie -g0 -march=x86-64 -DFACILITY=LOG_LOCAL1 -DNDEBUG -O2 -msse2 -fno-stack-protector -g0 -march=x86-64  -c -o rule_grammar.o rule_grammar.c
tcpspy.c: In function 'main':
tcpspy.c:721:7: warning: 'return' with no value, in function returning non-void
  721 |       return;
      |       ^~~~~~
tcpspy.c:527:5: note: declared here
  527 | int main (int argc, char *argv[])
      |     ^~~~
gcc -mx32 -msse2 -O2 -fno-stack-protector -no-pie -g0 -march=x86-64 -DFACILITY=LOG_LOCAL1 -DNDEBUG -O2 -msse2 -fno-stack-protector -g0 -march=x86-64  -c -o rule_lexer.o rule_lexer.c
In file included from rule_lexer.l:46:
rule_grammar.h:32:3: error: unknown type name 'u_int16_t'
   32 |   u_int16_t low, high;
      |   ^~~~~~~~~
rule_grammar.h:35:3: error: unknown type name 'u_int32_t'
   35 |   u_int32_t addr, mask;
      |   ^~~~~~~~~
rule_grammar.h:38:3: error: unknown type name 'u_int32_t'
   38 |   u_int32_t addr[4], mask[4];
      |   ^~~~~~~~~
make: *** [<builtin>: rule_lexer.o] Error 1
==================================================================================================================

==================================================================================================================
bugfix:
==================================================================================================================
1) If you haven't any header which defines u_int16_t. Do it yourself (wrong method):
------------------------------------------------------------------------------------------------------------------
 #include <stdint.h>
 #include <stddef.h>

 typedef uint16_t u_int16_t;
 typedef uint32_t u_int32_t;
 typedef size_t size_type;
------------------------------------------------------------------------------------------------------------------
or
------------------------------------------------------------------------------------------------------------------
2) You need to replace <u_int16_t>, <u_int32_t> with <uint16_t>, <uint32_t> and <size_type> with <size_t>.
==================================================================================================================