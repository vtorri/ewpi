#! /bin/sh

. ../../common.sh

sed -i -e "s|cmake_minimum_required(VERSION 2.8.12)|cmake_minimum_required(VERSION 3.6)|g" CMakeLists.txt
sed -i -e "s|LIBRARY|LIBRARY vorbis|g" win32/vorbis.def
sed -i -e "s|LIBRARY|LIBRARY vorbisenc|g" win32/vorbisenc.def
sed -i -e "s|LIBRARY|LIBRARY vorbisfile|g" win32/vorbisfile.def

ewpi_cmake "Ninja" \
    -DBUILD_SHARED_LIBS=ON \
    -DINSTALL_PKG_CONFIG_MODULE=ON
