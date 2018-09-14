#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
./configure --prefix=$3 --host=$4 --disable-static --enable-threads=vista --disable-lzmainfo --disable-lzma-links --disable-scripts --disable-doc --disable-cxx > ../config.log 2>&1
make V=0 -j install > ../make.log 2>&1
sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
