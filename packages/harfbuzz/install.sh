#! /bin/sh

. ../../common.sh

ewpi_meson \
    -Dcpp_std=c++17 \
    -Dintrospection=disabled \
    -Dtests=disabled \
    -Ddocs=disabled \
    -Dfreetype=enabled \
    -Dgdi=enabled \
    -Ddirectwrite=enabled \
    -Dgraphite2=enabled \
    -Dicu=enabled \
    -Dcairo=disabled \
    -Dtests=disabled \
    -Dglib=disabled \
    -Dgobject=disabled
