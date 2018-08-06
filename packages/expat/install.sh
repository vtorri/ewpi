#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1 > /dev/null
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
autoreconf -vif  > ../config.log 2>&1 && \
./configure --prefix=$3 --host=$4 --disable-static --with-docbook=no --without-xmlwf >> ../config.log 2>&1
make -j install > ../make.log 2>&1