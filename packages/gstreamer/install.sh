#! /bin/sh

. ../../common.sh

ewpi_meson \
    -Dcheck=disabled \
    -Dexamples=disabled \
    -Dtests=disabled \
    -Dbenchmarks=disabled \
    -Dgst_debug=false
