# ewpi
EFL Windows package installer

This project installs a set of libraries, most of them being compatible
with LGPL v2.1. The others are compatible with GPL v2 or AGPL v3, for use
with Etui. See below the list of installed libraries with their version
and license.

# Requirements:
 * mingw-w64 toolchain
 * tar
 * make
 * cmake
 * yasm
 * nasm
 * wget
 * gperf (native on Windows, not MSYS2 one)
 * python
 * meson >= 0.60.0
 * ninja
 * flex
 * bison

## Windows with MSYS2 32 bits

1. Install MSYS2 : https://www.msys2.org/ (steps 1 to 6)
2. run "pacman -S autoconf automake libtool tar git wget python bison gettext-devel make mingw-w64-i686-gperf mingw-w64-i686-nasm mingw-w64-i686-yasm mingw-w64-i686-cmake mingw-w64-i686-toolchain mingw-w64-x86_64-ninja mingw-w64-i686-python3-pip"
3. run "pip3 install meson"
4. Verify that meson >= 0.60.0 is installed

## Windows with MSYS2 64 bits

1. Install MSYS2 : https://www.msys2.org/ (steps 1 to 6)
2. run "pacman -S autoconf automake libtool tar git wget python bison gettext-devel make mingw-w64-x86_64gperf mingw-w64-x86_64-nasm mingw-w64-x86_64-yasm mingw-w64-x86_64-cmake mingw-w64-x86_64-toolchain mingw-w64-x86_64-ninja mingw-w64-x86_64-python3-pip"
3. run "pip3 install meson"
4. Verify that meson >= 0.60.0 is installed

## Fedora 32 bits

1. dnf install autoconf automake libtool cmake yasm nasm gperf python ninja-build mingw32-gcc mingw32-gcc-c++ mingw32-pkg-config python3-pip bison flex make gcc-c++
2. run "pip3 install meson"
3. Verify that meson >= 0.60.0 is installed

## Fedora 64 bits

1. dnf install autoconf automake libtool cmake yasm nasm gperf python ninja-build mingw64-gcc mingw64-gcc-c++ mingw64-pkg-config python3-pip bison flex make gcc-c++
2. run "pip3 install meson"
3. Verify that meson >= 0.60.0 is installed

# Compilation

after cloning ewpi and changing to the ewpi directory:

gcc -02 -std=c99 -o ewpi ewpi.c ewpi_map.c

# Usage

To see the usage, run "./ewpi --help", which returns:

```
Usage: D:\Documents\msys2\home\vtorri\gitroot\ewpi\ewpi.exe [OPTION]

Compile and install the EFL dependencies.

Optional arguments:
  --help        show this help message and exit
  --version     show the Ewpi version and exit
  --prefix=DIR  install in  DIR (must be an absolute path)
                  [default=$HOME/ewpi_$arch] $arch=32|64 base on
                  host value
  --host=VAL    host triplet, either i686-w64-mingw32 or x86_64-w64-mingw32
                  [default=x86_64-w64-mingw32]
  --arch=VAL    value passed to -march and -mtune gcc options
                  [default=i686|x86-64], depending on host value
  --winver=VAL  requested Windows version, win7 or win10 [default=win10]
  --verbose     verbose mode
  --strip       strip DLL
  --nsis        strip DLL and create the NSIS installer
  --efl         install the EFL
  --jobs=VAL    maximum number of used jobs [default=maximum]
  --clean       remove the archives and the created directories
                  (not removed by default)
```

Examples :

 * ./ewpi --prefix=/opt/ewpi_32 --host=i686-w64-mingw32
 * ./ewpi --host=x86_64-w64-mingw32 --efl --jobs=4 --clean

## Packages installed (84 packages)

### Libraries compatible with LGPL v2.1

 * brotli 1.0.9 (MIT)
 * bzip2 1.0.8 (BSD 4-clause, LGPL 2.1 compatible)
 * check 0.15.2(LGPL 2.1)
 * curl 7.83.1 (MIT)
 * dbus 1.12.20 (Academic Free License version 2.1)
 * expat 2.4.8 (MIT)
 * ffmpeg 5.0.1 (LGPL 2.1)
 * flac 1.3.3 (LGPL 2.1)
 * fontconfig 2.14.0 (MIT)
 * freetype 2.12.1 (FreeType license)
 * fribidi 1.0.12 (LGPL 2.1)
 * gettext 0.21.0 (only libintl : LGPL 2.1)
 * giflib 5.2.1 (MIT)
 * glib2 2.72.1 (LGPL 2.1)
 * graphene 1.10.8 (MIT)
 * graphite2 1.3.14 (LGPL 2.1)
 * gst-libav 1.20.1 (LGPL 2.1)
 * gst-plugins-base 1.20.1 (LGPL 2.1)
 * gst-plugins-good 1.20.1 (LGPL 2.1)
 * gstreamer 1.20.1 (LGPL 2.1)
 * harfbuzz 4.3.0 (MIT)
 * highway 0.16.0 (Apache 2.0)
 * iconv 0.0.8 (public domain)
 * icu 71.1 (MIT)
 * lcms2 2.13.1 (MIT)
 * libaacs 0.11.0 (LGPL 2.1)
 * libaom 3.3.0 (BSD 2-clause)
 * libarchive 3.6.1 (BSD 2-clause)
 * libass 0.16.0 (ISC)
 * libavif 0.10.0 (BSD 2-clause)
 * libbdplus 0.1.2 (LGPL 2.1)
 * libbluray 1.3.0 (LGPL 2.1)
 * libbs2b 3.1.0 (MIT)
 * libdav1d 1.0.0 (BSD 2-clause)
 * libdeflate 1.11 (MIT)
 * libexif 0.6.24 (LGPL v2.1)
 * libffi 3.4.2 (MIT)
 * libgcrypt 1.10.1 (LGPL 2.1)
 * libgme 0.6.3 (LGPL 2.1)
 * libgpg-error 1.44 (LGPL 2.1)
 * libgsm 1.0.19 (MIT)
 * libilbc 3.0.4 (BSD 3-clause)
 * libjpeg 2.1.3 (IJG and zlib)
 * libjxl git (BSD 3-clause)
 * libkvazaar 2.1.0 (BSD 3-clause)
 * liblerc 1.11 (Apache 2.0)
 * libmodplug 0.8.9 (public domain)
 * libmysofa 1.2.1 (BSD 3-clause)
 * libogg 1.3.5 (BSD 3-clause)
 * libopenh264 2.2.0 (BSD 2-clause)
 * libopenmpt 0.6.0 (BSD 3-clause)
 * libpng 1.6.37 (BSD 3-clause)
 * libpsl 0.21.1 (MIT)
 * libraw 0.20.2 (LGPL v2.1)
 * libressl 3.5.2 (Openssl and ISC licenses)
 * librtmp 2.4 (LGPL 2.1)
 * libsnappy 1.1.9 (BSD 3-clause)
 * libsndfile 1.1.0 (LGPL 2.1)
 * libsoxr 0.1.3 (LGPL 2.1)
 * libspeex 1.2.0 (BSD 3-clause)
 * libssh2 1.10.0 (BSD 3-clause)
 * libtheora 1.1.1 (BSD 3-clause)
 * libtiff 4.4.0 (BSD 2-clause)
 * libvmaf 2.3.1 (BSD -2-clause + patent)
 * libvorbis 1.3.7 (BSD 3-clause)
 * libwavpack 5.4.0 (BSD 3-clause)
 * libwebp 1.2.1 (BSD 3-clause)
 * libxml2 2.9.12 (MIT)
 * luajit 2.0.5 (MIT + public domain for some parts)
 * lz4 1.9.3 (BSD 2-clause for the library)
 * mp3lame 3.100 (LGPL 2.1)
 * mpg123 1.29.3 (LGPL 2.1)
 * nghttp2 1.47.0 (MIT)
 * openjpeg 2.5.0 (BSD 2-clause)
 * opus 1.3.1 (BSD 3-clause)
 * orc 0.4.32 (BSD 2-clause)
 * pixman 0.40.0 (MIT)
 * pkg-config 1.7.3
 * regex 1.2.1 (MIT)
 * taglib 1.12.1 (LGPL 2.1)
 * xz 5.2.5 (lzma : public domain)
 * zlib 1.2.12 (zlib license)
 * zstd 1.5.2 (BSD 3-clause)

### Libraries compatible with LGPL v3

 * libde265 1.0.8 (LGPL v3)
 * libheif 1.12.0 (LGPL v3)

### Libraries compatible with GPL v2

 * djvulibre 3.5.28 (GPL v2)

### Libraries compatible with AGPL v3

 * jbig2dec 0.17 (AGPL v3)
 * mupdf 1.19.0 (AGPL v3)
