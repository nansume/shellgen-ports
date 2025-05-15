#!/bin/sed -f
#^config.h

# #define HAVE_SSLv23_client_method 1
# #define HAVE_SSLv23_server_method 1
# /* #undef HAVE_SAMPLE_test */
s|^\(#define HAVE_SSLv23_.*_method\) 1$|/* \1 */|