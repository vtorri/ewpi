#! /bin/sh

. ../../common.sh

sed -i -e "s/subdir('test')//g" meson.build

ewpi_meson \
    -Dgtk=disabled \
    -Dlibpng=disabled
