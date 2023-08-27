#! /bin/sh

. ../../common.sh

# native compilation

rm -rf source_native && mkdir source_native
cp -r \
   data/ \
   meson.build \
   meson_options.txt \
   po/ \
   shared-mime-info.pc.in \
   src/ \
   tests/ \
   xdgmime/ \
   source_native
cd source_native
sed -i -e "s/if xmlto.found()/if false/g" data/meson.build
meson setup \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --default-library shared \
      -Dupdate-mimedb=true \
      builddir > ../config.log 2>&1

ninja $verbninja -C builddir
cd ..

# cross compiled compilation

cp ../cross_toolchain.txt .

if test "x$4" = "xi686-w64-mingw32" ; then
    sed -i -e 's/@cpu_family@/x86/g;s/@cpu@/i686/g' cross_toolchain.txt
else
    sed -i -e 's/@cpu_family@/x86_64/g;s/@cpu@/x86_64/g' cross_toolchain.txt
fi

sed -i -e "s/@host@/$4/g;s/@arch@/$1/g;s|@prefix@|$3|g" cross_toolchain.txt
sed -i -e "s/if xmlto.found()/if false/g" data/meson.build

rm -rf builddir
meson setup \
      --prefix=$3 \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --cross-file cross_toolchain.txt \
      --default-library shared \
      -Dupdate-mimedb=false \
      builddir > ../config.log 2>&1

ninja $verbninja -C builddir install > ../make.log 2>&1

./source_native/builddir/src/update-mime-database $3/share/mime
