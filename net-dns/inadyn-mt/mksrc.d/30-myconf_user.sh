DESCRIPTION="A simple dynamic DNS client"
HOMEPAGE="https://sourceforge.net/projects/inadyn-mt/"
LICENSE="GPL-3"
IUSE="-debug -sound"

MYCONF="${MYCONF}
 $(use_enable 'debug')
 $(use_enable 'sound')
"
