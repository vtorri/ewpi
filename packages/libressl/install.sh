#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

cd packages/$1
dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
sed -i -e 's/SUBDIRS = crypto ssl tls include apps tests man/SUBDIRS = crypto ssl tls include apps tests/g' Makefile.in
./configure --prefix=$3 --host=$4 --disable-static --enable-windows-ssp > ../config.log 2>&1
make -j $jobopt install > ../make.log 2>&1
sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
