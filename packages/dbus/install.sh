#! /bin/sh

. ../../common.sh

sed -i -e "s/subdir('test')//g;s/subdir('doc')//g;s/subdir('cmake')//g" meson.build

ewpi_meson \
    -Dmodular_tests=disabled \
    -Drelocation=disabled \
    -Dselinux=disabled \
    -Dapparmor=disabled \
    -Dlibaudit=disabled \
    -Dinotify=disabled \
    -Dkqueue=disabled \
    -Depoll=disabled \
    -Dlaunchd=disabled \
    -Dsystemd=disabled \
    -Ddoxygen_docs=disabled \
    -Dducktype_docs=disabled \
    -Dqt_help=disabled \
    -Dstats=false \
    -Dtools=false \
    -Dtraditional_activation=false \
    -Duser_session=false \
    -Dx11_autolaunch=disabled \
    -Dxml_docs=disabled
