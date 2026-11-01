#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DENABLE_SDL=OFF \
    -DENABLE_DECODER=OFF
