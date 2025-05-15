#!/bin/sed -f
#^etc/mc/filehighlight.ini

/extensions=ada;/ s|\(;mjs;\)|;md\1|