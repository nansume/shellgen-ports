# Copyright 1999-2023 Gentoo Authors, GPLv2

CMAKEFLAGS="${CMAKEFLAGS}
 -DCMAKE_CXX_STANDARD=14 # C++14 or later required for >=gtest-1.13.0
 -DHAVE_CRC32C=ON
 -DLEVELDB_BUILD_BENCHMARKS=OFF
 -DHAVE_SNAPPY=$(usex snappy)
 -DHAVE_TCMALLOC=$(usex tcmalloc)
 -DLEVELDB_BUILD_TESTS=$(usex test)
"