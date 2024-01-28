#! /bin/sh

. ../../common.sh

cd source

mkdir -p $3/include/utf8cpp/utf8
cp utf8.h $3/include/utf8cpp
cp utf8/* $3/include/utf8cpp/utf8
