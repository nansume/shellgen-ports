# +static +static-libs -shared +nopie +nodebug -lfs -upx +patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="Contains a socks5 server, a reverse socks server and client, a netcat like tool and a socks5 relay."
HOMEPAGE="https://sourceforge.net/projects/ssocks/"
LICENSE="MIT"

# bug: checking for SSL_library_init in -lssl... no
#MYCONF="${MYCONF}
# --with-ssl
#"
