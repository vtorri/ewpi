#! /bin/bash

# $1 : prefix
# $2 : host

find $1/bin -name "*.dll" -exec $2-strip {} \; > strip.log 2>&1
find $1/lib -name "*.dll" -exec $2-strip {} \; >> strip.log 2>&1

cp -f ewpi.nsi.in ewpi.nsi
path=`echo $1 | sed 's,/,\\\\\\\\,g'`
echo $path

sed -i -e "s|@prefix@|${path}|g" ewpi.nsi
