#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

if test "x$4" = "xi686-w64-mingw32" ; then
    sed -i -e 's/@cpu_family@/x86/g;s/@cpu@/i686/g' cross_toolchain.txt
else
    sed -i -e 's/@cpu_family@/x86_64/g;s/@cpu@/x86_64/g' cross_toolchain.txt
fi

sed -i -e "s/@host@/$4/g;s/@arch@/$1/g;s|@prefix@|$3|g" cross_toolchain.txt

sed -i -e "s/subdir('test')//g;s/subdir('doc')//g;s/subdir('cmake')//g" meson.build

rm -rf builddir
meson setup \
      --prefix=$3 \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --cross-file cross_toolchain.txt \
      --default-library shared \
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
      -Dxml_docs=disabled \
      builddir > ../config.log 2>&1

ninja $verbninja -C builddir install > ../make.log 2>&1
