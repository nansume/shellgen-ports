# http://gpo.zugaina.org/net-dns/inadyn-mt

DESCRIPTION="A simple dynamic DNS client (nossl,Lang-C)"
HOMEPAGE="https://sourceforge.net/projects/inadyn-mt/"
LICENSE="GPL-3"
IUSE="-debug -sound"

MYCONF="${MYCONF}
 $(use_enable 'debug')
 $(use_enable 'sound')
"
