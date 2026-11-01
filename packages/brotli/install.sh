#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBROTLI_DISABLE_TESTS=ON
