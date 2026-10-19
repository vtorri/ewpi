#! /bin/sh

. ../../common.sh

ewpi_meson \
    -Dgl=disabled \
    -Dexamples=disabled \
    -Dtests=disabled
