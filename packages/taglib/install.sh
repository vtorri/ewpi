#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DBUILD_BINDINGS:BOOL=ON \
    -DBUILD_TESTING=OFF \
    -DZLIB_ROOT=$prefix_unix
