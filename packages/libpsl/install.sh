#! /bin/sh

. ../../common.sh

sed -i -e "s/subdir('tools')//g" meson.build

ewpi_meson \
    -Druntime=libicu \
    -Dtests=false
