#!/bin/sed -f
#^src/dbinc/atomic.h
# https://www.linuxfromscratch.org/blfs/view/svn/server/db.html

s|\(__atomic_compare_exchange\)|\1_db|