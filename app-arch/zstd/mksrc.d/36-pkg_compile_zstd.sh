#!/bin/sh
# 2021
# Date: 2023-10-15 08:00 UTC - Log: near to compat-posix

# Build
test "x${USER}" != 'xroot' && {
  cd "${WORKDIR}/"

  ${IONICE_COMM} make ${MAKEFLAGS} \
   ZSTD_LEGACY_SUPPORT="0" \
   HAVE_LZ4="0" \
   HAVE_ZLIB="0" \
   HAVE_LZMA="0" \
   "zstd" "lib"
}
