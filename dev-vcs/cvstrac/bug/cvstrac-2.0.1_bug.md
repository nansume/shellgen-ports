==================================================================================================================
dev-vcs/cvstrac-2.0.1 - error: unknown type name 'time_t'
==================================================================================================================
gcc -g -O0 -Wall -mx32 -msse2 -ffunction-sections -fdata-sections -Os -fno-stack-protector -no-pie -g0 -march=x86-64 -I. -I/build/cvstrac-2.0.1 -o attach.o -c attach_.c
In file included from attach_.c:28:
attach.h:12:28: error: unknown type name 'time_t'; did you mean 'size_t'?
   12 | char *cgi_rfc822_datestamp(time_t now);
      |                            ^~~~~~
      |                            size_t
attach.h:14:25: error: unknown type name 'time_t'; did you mean 'size_t'?
   14 | void cgi_modified_since(time_t objectTime);
      |                         ^~~~~~
      |                         size_t
attach_.c: In function 'output_attachment_callback':
attach_.c:224:3: warning: implicit declaration of function 'cgi_modified_since' [-Wimplicit-function-declaration]
  224 |   cgi_modified_since(atoi(azArg[3]));
      |   ^~~~~~~~~~~~~~~~~~
attach_.c:226:37: warning: implicit declaration of function 'cgi_rfc822_datestamp' [-Wimplicit-function-declaration]
  226 |     mprintf("Last-Modified: %s\r\n",cgi_rfc822_datestamp(atoi(azArg[3]))));
      |                                     ^~~~~~~~~~~~~~~~~~~~
make: *** [/build/cvstrac-2.0.1/main.mk:138: attach.o] Error 1
------------------------------------------------------------------------------------------------------------------
Failed make build
==================================================================================================================