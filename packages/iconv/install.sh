#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
make clean > ../make.log 2>&1
make -j install prefix=$3 CC=$4-gcc AR=$4-ar RANLIB=$4-ranlib DLLTOOL=$4-dlltool >> ../make.log 2>&1
