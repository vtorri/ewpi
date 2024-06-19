#! /bin/sh

. ../../common.sh

cp ../cross_toolchain.txt .

if test "x$4" = "xi686-w64-mingw32" ; then
    sed -i -e 's/@cpu_family@/x86/g;s/@cpu@/i686/g' cross_toolchain.txt
else
    sed -i -e 's/@cpu_family@/x86_64/g;s/@cpu@/x86_64/g' cross_toolchain.txt
fi

sed -i -e "s/@host@/$4/g;s/@arch@/$1/g;s|@prefix@|$3|g" cross_toolchain.txt

export EWPI_PREFIX=$HOME/ewpi_64
export PATH=$EWPI_PREFIX/bin:$PATH
export PKG_CONFIG_PATH=$EWPI_PREFIX/lib/pkgconfig
export CPPFLAGS="-I$EWPI_PREFIX/include -DECORE_WIN32_WIP_POZEFLKSD"
export CFLAGS="-O2 -pipe"
export CXXFLAGS="-O2 -pipe"
export LDFLAGS=-L$EWPI_PREFIX/lib

rm -rf builddir
meson setup \
      --prefix=$HOME/efl_64 \
      --libdir=lib \
      --buildtype=release \
      --strip \
      --cross-file cross_toolchain.txt \
      --default-library shared \
      -Dsystemd=false \
      -Dpulseaudio=false \
      -Dv4l2=false \
      -Dlibmount=false \
      -Deeze=false \
      -Dx11=false \
      -Dxinput2=false \
      -Dinput=false \
      -Decore-imf-loaders-disabler='xim','ibus','scim' \
      -Devas-loaders-disabler='pdf','ps','rsvg','json','tga','tgv' \
      -Dopengl=none \
      -Dpixman=true \
      -Dembedded-lz4=false \
      -Dbuild-examples=false \
      -Dbuild-tests=false \
      -Dbindings='lua','cxx' \
      -Delua=true \
      -Dwindows-version=win10 \
      builddir \
      > ../config.log 2>&1

ninja $verbninja -C builddir install > ../make.log 2>&1
