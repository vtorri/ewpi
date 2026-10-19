#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBUILD_SHARED_LIBS=ON \
    -DSNAPPY_BUILD_TESTS=OFF \
    -DSNAPPY_BUILD_BENCHMARKS=OFF \
    -DSNAPPY_REQUIRE_AVX=ON \
    -DSNAPPY_REQUIRE_AVX2=ON
