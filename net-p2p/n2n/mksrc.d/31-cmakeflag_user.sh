# -static -static-libs +shared -lfs -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

# http://gpo.zugaina.org/net-p2p/n2n

DESCRIPTION="A Layer Two Peer-to-Peer VPN"
HOMEPAGE="http://www.ntop.org/n2n/"
LICENSE="GPL-3"
IUSE="+openssl -caps -pcap -zstd -upnp"

CMAKEFLAGS="${CMAKEFLAGS}
 -DBUILD_SHARED_LIBS=OFF
 -DN2N_OPTION_USE_OPENSSL=$(usex 'openssl' ON OFF)
 -DN2N_OPTION_USE_CAPLIB=$(usex 'caps' ON OFF)
 -DN2N_OPTION_USE_PCAPLIB=$(usex 'pcap' ON OFF)
 -DN2N_OPTION_USE_ZSTD=$(usex 'zstd' ON OFF)
 -DN2N_OPTION_USE_PORTMAPPING=$(usex 'upnp' ON OFF)
"
