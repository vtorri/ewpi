#! /bin/sh

. ../../common.sh

sed -i -e "s/subdir('test')//g" meson.build

ewpi_meson \
    -Dextra-programs=disabled \
    -Dtests=disabled \
    -Ddocs=disabled
