#! /bin/sh

. ../../common.sh

sed -i -e "s/Windows.h/windows.h/g" src/lcms2.rc.in

ewpi_meson \
    -Djpeg=disabled \
    -Dtiff=disabled
