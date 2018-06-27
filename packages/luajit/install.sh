#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
make -j install prefix=$3 HOST_CC=gcc CROSS=$4- TARGET_SYS=Windows > ../make.log 2>&1
