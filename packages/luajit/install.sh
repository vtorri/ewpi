#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
arch=
if test "x$4" = "xi686-w64-mingw32"; then
    arch="-m32"
fi
make -j install PREFIX=$3 HOST_CC="gcc $arch" CROSS=$4- TARGET_SYS=Windows > ../make.log 2>&1
