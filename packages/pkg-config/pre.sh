#! /bin/sh

# $1 : name
# $2 : taropt
# $3 : tarname

cd packages/$1
tar x$2 $3 &> pre.log
