#! /bin/sh

# $1 : name
# $2 : taropt
# $3 : tarname
# $4 : taropt2

cd packages/$1
tar $2 $3 > pre.log 2>&1
#patch -p0 < Makefile.diff >> pre.log 2>&1
