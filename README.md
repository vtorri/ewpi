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
 * autotools
 * python
 * perl
 * meson >= 0.60.0
 * ninja
 * flex
 * bison
 * nsis

To build the NSIS installer, the EnVar plug-in is mandatory. See https://nsis.sourceforge.io/EnVar_plug-in for the latest link and documentation.

## Windows with MSYS2 32 bits

1. Install MSYS2 : https://www.msys2.org/ (steps 1 to 4)
2. In the start menu,launch `MSYS2 64bit` --> `MSYS2 MINGW32`
3. In the terminal, launch `pacman -Syu`, press `Y` to proceed the installation. Press `Y` to close the terminal
4. In the start menu, launch again `MSYS2 64bit` --> `MSYS2 MINGW32`
5. Run `pacman -Syu base-devel autoconf automake libtool tar git wget python flex bison gettext-devel pkgconf make mingw-w64-i686-gettext-tools mingw-w64-i686-gperf mingw-w64-i686-nasm mingw-w64-i686-yasm mingw-w64-i686-cmake mingw-w64-i686-openmp mingw-w64-i686-toolchain mingw-w64-i686-ninja mingw-w64-i686-meson mingw-w64-i686-nsis
6. When aksed for the selection, just press the Enter key for the default selection
7. Press `Y` to proceed the installation. This may take several minutes

## Windows with MSYS2 64 bits

1. Install MSYS2 : https://www.msys2.org/ (steps 1 to 4)
2. In the start menu,launch `MSYS2 64bit` --> `MSYS2 MINGW64`
3. In the terminal, launch `pacman -Syu`, press `Y` to proceed the installation. Press `Y` to close the terminal
4. In the start menu,launch again `MSYS2 64bit` --> `MSYS2 MINGW64`
5. Run `pacman -Syu base-devel autoconf automake libtool tar git wget python perl flex bison gettext-devel pkgconf make mingw-w64-x86_64-gettext-tools mingw-w64-x86_64-gperf mingw-w64-x86_64-nasm mingw-w64-x86_64-yasm mingw-w64-x86_64-cmake mingw-w64-x86_64-openmp mingw-w64-x86_64-toolchain mingw-w64-x86_64-ninja mingw-w64-x86_64-meson mingw-w64-x86_64-nsis
6. When aksed for the selection, just press the Enter key for the default selection
7. Press `Y` to proceed the installation This may take several minutes

## Fedora 32 bits

1. dnf install autoconf automake libtool gettext cmake yasm nasm gperf python perl ninja-build pkgconf mingw32-libgomp mingw32-gcc mingw32-gcc-c++ python3-pip bison flex make gcc-c++ mingw32-nsis
2. run "pip3 install meson"
3. Verify that meson >= 0.60.0 is installed

## Fedora 64 bits

1. dnf install autoconf automake libtool gettext cmake yasm nasm gperf python perl ninja-build pkgconf mingw64-libgomp mingw64-gcc mingw64-gcc-c++ python3-pip bison flex make gcc-c++ mingw32-nsis
2. run "pip3 install meson"
3. Verify that meson >= 0.60.0 is installed

## Ubuntu 22.10 64 bits

1. apt install autoconf automake libtool cmake yasm nasm gperf ninja-build pkgconf g++-mingw-w64-x86-64 python3-pip perl bison flex nsis
2. run "pip3 install meson"
3. Verify that meson >= 0.60.0 is installed

# Compilation

after cloning ewpi and changing to the ewpi directory:

gcc -O2 -std=c99 -o ewpi ewpi.c ewpi_map.c

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

## Packages installed (88 packages)

### Libraries compatible with LGPL v2.1

 * brotli 1.1.0 (MIT)
 * bzip2 1.0.8 (BSD 4-clause, LGPL 2.1 compatible)
 * check 0.15.2(LGPL 2.1)
 * curl 8.8.0 (MIT)
 * dbus 1.14.10 (Academic Free License version 2.1)
 * dejavu-fonts 2.37
 * expat 2.6.2 (MIT)
 * ffmpeg 7.0.0 (LGPL 2.1)
 * flac 1.4.3 (LGPL 2.1)
 * fontconfig 2.14.2 (MIT)
 * freetype 2.13.2 (FreeType license)
 * fribidi 1.0.15 (LGPL 2.1)
 * gettext 0.22.4 (only libintl : LGPL 2.1)
 * giflib 5.2.2 (MIT)
 * glib2 2.76.3 (LGPL 2.1)
 * graphene 1.10.8 (MIT)
 * graphite2 1.3.14 (LGPL 2.1)
 * gst-libav 1.24.3 (LGPL 2.1)
 * gst-plugins-base 1.24.3 (LGPL 2.1)
 * gst-plugins-good 1.24.3 (LGPL 2.1)
 * gstreamer 1.24.3 (LGPL 2.1)
 * harfbuzz 9.0.0 (MIT)
 * highway 1.2.0 (Apache 2.0)
 * iconv 0.0.8 (public domain)
 * icu 75.1 (MIT)
 * lcms2 2.16 (MIT)
 * libaacs 0.11.1 (LGPL 2.1)
 * libaom 3.9.1 (BSD 2-clause)
 * libarchive 3.7.4 (BSD 2-clause)
 * libass 0.17.3 (ISC)
 * libavif 1.0.4 (BSD 2-clause)
 * libbdplus 0.2.0 (LGPL 2.1)
 * libblake2 0.98.1 (CC0 1.0)
 * libbluray 1.3.4 (LGPL 2.1)
 * libbs2b 3.1.0 (MIT)
 * libdav1d 1.4.3 (BSD 2-clause)
 * libdeflate 1.20 (MIT)
 * libexif 0.6.24 (LGPL v2.1)
 * libffi 3.4.6 (MIT)
 * libgcrypt 1.11.0 (LGPL 2.1)
 * libgme 0.6.3 (LGPL 2.1)
 * libgpg-error 1.50 (LGPL 2.1)
 * libgsm 1.0.22 (MIT)
 * libilbc 3.0.4 (BSD 3-clause)
 * libjpeg 3.0.3 (IJG and zlib)
 * libjxl 0.10.3 (BSD 3-clause)
 * libkvazaar 2.3.1 (BSD 3-clause)
 * liblerc 4.0.0 (Apache 2.0)
 * libmodplug 0.8.9 (public domain)
 * libmysofa 1.3.2 (BSD 3-clause)
 * libogg 1.3.5 (BSD 3-clause)
 * libopenh264 2.4.1 (BSD 2-clause)
 * libopenmpt 0.7.3 (BSD 3-clause)
 * libpng 1.6.43 (BSD 3-clause)
 * libpsl 0.21.5 (MIT)
 * libraw 0.21.2 (LGPL v2.1)
 * libsnappy 1.2.1 (BSD 3-clause)
 * libsndfile 1.2.2 (LGPL 2.1)
 * libsoxr 0.1.3 (LGPL 2.1)
 * libssh2 1.11.0 (BSD 3-clause)
 * libtiff 4.6.0 (BSD 2-clause)
 * libvmaf 3.0.0 (BSD -2-clause + patent)
 * libvorbis 1.3.7 (BSD 3-clause)
 * libwavpack 5.6.0 (BSD 3-clause)
 * libwebp 1.4.0 (BSD 3-clause)
 * libxml2 2.13.1 (MIT)
 * libyuv 1.88.7 (BSD 3-clause)
 * luajit 2.1.20240311 (MIT + public domain for some parts)
 * lz4 1.9.4 (BSD 2-clause for the library)
 * mp3lame 3.100 (LGPL 2.1)
 * mpg123 1.32.6 (LGPL 2.1)
 * nghttp2 1.62.1 (MIT)
 * openjpeg 2.5.2 (BSD 2-clause)
 * openssl 3.3.0 (Apache 2.0)
 * opus 1.5.2 (BSD 3-clause)
 * orc 0.4.38 (BSD 2-clause)
 * pixman 0.43.4 (MIT)
 * regex 1.2.1 (MIT)
 * utfcpp 4.0.5 (BSL 1.0)
 * taglib 2.0.1 (LGPL 2.1)
 * xz 5.6.2 (lzma : public domain)
 * zlib 1.3.1 (zlib license)
 * zstd 1.5.6 (BSD 3-clause)

### Libraries compatible with LGPL v3

 * libde265 1.0.15 (LGPL v3)
 * libheif 1.17.6 (LGPL v3)

### Libraries compatible with GPL v2

 * djvulibre 3.5.28 (GPL v2)
 * shared-mime-info 2.4 (GPL v2: tool generating mime types, not distributed)

### Libraries compatible with AGPL v3

 * jbig2dec 0.20 (AGPL v3)
 * mupdf 1.24.2 (AGPL v3)
