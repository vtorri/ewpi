#! /bin/sh

. ../../common.sh

sed -i -e "s/'-Werror=missing-include-dirs/#'-Werror=missing-include-dirs/g" meson.build
sed -i -e "s/subdir('tests')//g" gio/meson.build

ewpi_meson \
    -Dforce_posix_threads=false \
    -Dtests=false \
    -Dglib_debug=disabled \
    -Dglib_assert=false \
    -Dglib_checks=false \
    -Dlibelf=disabled
