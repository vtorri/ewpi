#! /bin/bash

# $1 : prefix
# $2 : version
# $3 : host (i686|x86_64)
# $4 : arch_suf (32|64)
# $5 : winver

path=`echo $1 | sed 's,/,\\\\\\\\,g'`
echo $path

path=$HOME/efl_64
version=1.26


cp -f efl.nsi.in efl.nsi

sed -i -e "s|@prefix@|${path}|g;s|@version@|$version|g;s|@arch@|$3|g;s|@arch_suf@|$4|g;s|@winver@|$5|g" efl.nsi
makensis efl.nsi > efl_nsis.log 2>&1
