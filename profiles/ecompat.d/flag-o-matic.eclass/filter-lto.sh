#!/bin/sh
# https://devmanual.gentoo.org/eclass-reference/flag-o-matic.eclass/index.html
# https://gitweb.gentoo.org/repo/gentoo.git/plain/eclass/flag-o-matic.eclass
# https://wiki.gentoo.org/wiki/LTO

filter_lto() { filter-flags -flto;}

# hush - not implementation <alias> - replace to: func name no posix
if typeis 'alias'; then
  alias filter-lto='filter_lto'
fi
# name func no-posix
if ! typeis 'alias'; then
  append-lfs-flags() { filter_lto $@;}
fi
