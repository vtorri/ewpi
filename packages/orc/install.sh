#! /bin/sh

. ../../common.sh

ewpi_meson \
    -Dbenchmarks=disabled \
    -Dexamples=disabled \
    -Dgtk_doc=disabled \
    -Dtests=disabled \
    -Dorc-test=disabled
