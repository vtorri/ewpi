#! /bin/sh

. ../../common.sh

ewpi_meson \
    -Dsoup=disabled \
    -Dexamples=disabled \
    -Dtests=disabled
