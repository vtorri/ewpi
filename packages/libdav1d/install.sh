#! /bin/sh

. ../../common.sh

ewpi_meson \
    -Denable_tests=false \
    -Dlogging=false
