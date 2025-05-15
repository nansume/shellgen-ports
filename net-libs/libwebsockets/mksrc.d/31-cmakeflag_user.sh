# -static -static-libs +shared -lfs -mbedtls -upx -patch -doc -man -xstub -diet +musl +stest +strip +x32

DESCRIPTION="A flexible pure-C library for implementing network protocols"
HOMEPAGE="https://libwebsockets.org/"
LICENSE="MIT"

IUSE="+access-log -caps +cgi +client -dbus -extensions -generic-sessions -http-proxy"
IUSE="${IUSE} -http2 +ipv6 +lejp -libev -libevent +libuv -mbedtls -peer-limits"
IUSE="${IUSE} -server-status +smtp -socks5 -sqlite3 +ssl +threads +zip"

CMAKEFLAGS="${CMAKEFLAGS}
 -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
 -DDISABLE_WERROR=ON
 -DLWS_BUILD_HASH=unknown
 -DLWS_HAVE_LIBCAP=$(usex caps)
 -DLWS_IPV6=$(usex ipv6)
 -DLWS_ROLE_DBUS=$(usex dbus)
 -DLWS_WITHOUT_CLIENT=$(usex !client)
 -DLWS_WITHOUT_TEST_CLIENT=$(usex !client)
 -DLWS_WITH_ACCESS_LOG=$(usex access-log)
 -DLWS_WITH_CGI=$(usex cgi)
 -DLWS_WITH_GENERIC_SESSIONS=$(usex generic-sessions)
 -DLWS_WITH_HTTP2=$(usex http2)
 -DLWS_WITH_HTTP_PROXY=$(usex http-proxy)
 -DLWS_WITH_HUBBUB=$(usex http-proxy)
 -DLWS_WITH_LEJP=$(usex lejp)
 -DLWS_WITH_LIBEV=$(usex libev)
 -DLWS_WITH_LIBEVENT=$(usex libevent)
 -DLWS_WITH_LIBUV=$(usex libuv)
 -DLWS_WITH_MBEDTLS=$(usex mbedtls)
 -DLWS_WITH_PEER_LIMITS=$(usex peer-limits)
 -DLWS_WITH_SERVER_STATUS=$(usex server-status)
 -DLWS_WITH_SMTP=$(usex smtp)
 -DLWS_WITH_SOCKS5=$(usex socks5)
 -DLWS_WITH_SQLITE3=$(usex sqlite3)
 -DLWS_WITH_SSL=$(usex ssl)
 -DLWS_WITH_STATIC=OFF
 -DLWS_WITH_STRUCT_JSON=$(usex lejp)
 -DLWS_WITH_THREADPOOL=$(usex threads)
 -DLWS_WITH_ZIP_FOPS=$(usex zip)
 -DLWS_WITHOUT_EXTENSIONS=$(usex !extensions)
 -DLWS_WITHOUT_TESTAPPS=ON
"
