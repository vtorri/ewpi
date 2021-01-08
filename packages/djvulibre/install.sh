#! /bin/sh

. ../../common.sh

sed -i -e 's/libdjvulibre_la_CPPFLAGS =/libdjvulibre_la_CPPFLAGS = -DDJVUAPI_EXPORT -DDDJVUAPI_EXPORT -DMINILISPAPI_EXPORT/g' libdjvu/Makefile.in

export LIBS="-liconv $LIBS"

./configure --prefix=$3 --host=$4 --disable-static > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
