# ewpi
EFL Windows package installer

# Requirements:
 * mingw-w64 toolchain (rename ar, dlltool, ranlib, strip and windres with the host prefix when compiling on Windows)
 * make
 * cmake
 * yasm (on UNIX)
 * nasm (on UNIX)
 * wget
 * gperf
 * python
 * meson
 * ninja
 * flex
 * bison

## Windows with MSYS2

1. Install MSYS2 : https://www.msys2.org/ (steps 1 to 6)
2. run "pacman -S git gettext-devel make cmake wget gperf python bison mingw-w64-x86_64-toolchain mingw-w64-i686-toolchain mingw-w64-x86_64-ninja mingw-w64-x86_64-python3-pip"
3. run "pip3 install meson"
4. unset PKG_CONFIG_PATH

## Fedora 32 bits

1. dnf install cmake yasm nasm gperf python ninja-build mingw32-gcc mingw32-gcc-c++ python3-pip
2. run "pip3 install meson"

## Fedora 64 bits

1. dnf install cmake yasm nasm gperf python ninja-build mingw64-gcc mingw64-gcc-c++ python3-pip
2. run "pip3 install meson"

# Compilation

gcc -std=c99 -o ewpi ewpi.c ewpi_map.c

# Usage

To see the usage, run "./ewpi --help", which returns:
```
Usage: D:\Documents\msys2\home\vtorri\gitroot\ewpi\ewpi.exe [OPTION]

Compile and install the EFL dependencies.

Optional arguments:
  --help        show this help message and exit
  --prefix=DIR  install in  DIR (must be an absolute path)
                  [default=$HOME/ewpi_$arch] $arch=32|64 base on
                  host value
  --host=VAL    host triplet, either i686-w64-mingw32 or x86_64-w64-mingw32
                  [default=x86_64-w64-mingw32]
  --arch=VAL    value passed to -march and -mtune gcc options
                  [default=i686|x86-64], depending on host value
  --efl=yes|no  whether installing the EFL [default=no]
  --jobs=VAL    maximum number of used jobs [default=maximum]
  --clean       remove the archives and the created directories
                  (not removed by default)
```
Examples :

 * ./ewpi --prefix=/opt/ewpi_32 --host=i686-w64-mingw32
 * ./ewpi --host=x86_64-w64-mingw32 --efl=yes --jobs=4 --clean

## Packages installed

 * bullet
 * bzip2
 * cairo
 * cares
 * check
 * curl
 * dbus
 * expat
 * flac
 * fontconfig
 * freetype
 * freetype_bootstrap
 * fribidi
 * gettext
 * giflib
 * glib2
 * graphene
 * graphite2
 * gst-plugins-base
 * gst-plugins-good
 * gstreamer
 * harfbuzz
 * iconv
 * libidn2
 * libjpeg
 * libogg
 * libpng
 * libpsl
 * libressl
 * libsndfile
 * libspeex
 * libssh2
 * libtheora
 * libtiff
 * libunistring
 * libvisual
 * libvorbis
 * libwebp
 * libxml2
 * luajit
 * lz4
 * mpg123
 * nasm
 * nghttp2
 * openjpeg
 * opus
 * orc
 * pixman
 * pkg-config
 * regex
 * xz
 * yasm
 * zlib
