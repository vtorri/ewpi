#! /bin/sh

. ../../common.sh

# native compilation
export CPPFLAGS="$CPPFLAGS -I$3/include/libxml2"

rm -rf builddir

sed -i -e "s/xmlto.found()/false/g" data/meson.build

meson setup \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --default-library shared \
      -Dupdate-mimedb=true \
      -Dbuild-translations=false \
      -Dbuild-tests=false \
      builddir > ../config.log 2>&1

ninja $verbninja -C builddir > ../make.log 2>&1

mkdir -p $3/share/mime/packages
./builddir/src/update-mime-database $3/share/mime
