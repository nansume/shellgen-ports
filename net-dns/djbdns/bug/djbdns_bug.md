==================================================================================================================
net-dns/djbdns-1.05 - undefined reference to `errno'
==================================================================================================================
./compile response.c
./compile dd.c
./compile roots.c
./compile iopause.c
./load chkshsgr
./makelib dns.a dns_dfd.o dns_domain.o dns_dtda.o dns_ip.o \
dns_ipq.o dns_mx.o dns_name.o dns_nd.o dns_packet.o \
dns_random.o dns_rcip.o dns_rcrw.o dns_resolve.o \
dns_sortip.o dns_transmit.o dns_txt.o
./makelib env.a env.o
./makelib alloc.a alloc.o alloc_re.o getln.o getln2.o \
stralloc_cat.o stralloc_catb.o stralloc_cats.o \
stralloc_copy.o stralloc_eady.o stralloc_num.o \
stralloc_opyb.o stralloc_opys.o stralloc_pend.o
./makelib cdb.a cdb.o cdb_hash.o cdb_make.o
./makelib getopt.a sgetopt.o subgetopt.o
./load random-ip dns.a libtai.a buffer.a unix.a byte.a
./load dnsqr iopause.o printrecord.o printpacket.o \
parsetype.o dns.a env.a libtai.a buffer.a alloc.a unix.a \
byte.a  `cat socket.lib`
/bin/ld: buffer.a(buffer_put.o): in function `buffer_flush':
buffer_put.c:(.text+0x58): undefined reference to `errno'
/bin/ld: buffer.a(buffer_put.o): in function `buffer_put':
buffer_put.c:(.text+0x1c8): undefined reference to `errno'
/bin/ld: buffer.a(buffer_put.o): in function `buffer_putflush':
buffer_put.c:(.text+0x2a8): undefined reference to `errno'
collect2: error: ld returned 1 exit status
make: *** [Makefile:699: random-ip] Error 1
==================================================================================================================