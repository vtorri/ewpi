#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt2

cd packages/$1
dir_name=`tar $5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name
arch="-m64"
if test "x$4" = "xi686-w64-mingw32"; then
    arch="-m32"
fi
sed -i -e 's%$(INSTALL_X) $(FILE_T) $(INSTALL_T)%cp $(FILE_T) $(INSTALL_BIN)/luajit.tmp%g' Makefile
sed -i -e 's%INSTALL_DYN= $(INSTALL_LIB)/$(INSTALL_SONAME)%INSTALL_DYN= $(INSTALL_BIN)/$(INSTALL_SONAME)%g' Makefile
sed -i -e 's%$(SYMLINK) $(INSTALL_SONAME) $(INSTALL_SHORT1) &&%$(INSTALL_F) $(INSTALL_SOSHORT1) $(INSTALL_SHORT1) ||%g' Makefile
sed -i -e 's%$(SYMLINK) $(INSTALL_SONAME) $(INSTALL_SHORT2) || :% :%g' Makefile
sed -i -e 's%$(SYMLINK) $(INSTALL_TNAME) $(INSTALL_TSYM)%%g' Makefile
make \
    install \
    PREFIX=$3 \
    HOST_CC="gcc $arch" \
    CROSS=$4- \
    TARGET_SYS=Windows \
    BUILDMODE=dynamic \
    SYMLINK=cp \
    INSTALL_X=cp \
    INSTALL_F=cp \
    FILE_T=luajit.exe \
    INSTALL_TNAME=luajit.exe \
    INSTALL_TSYMNAME=luajit.exe \
    FILE_SO=lua51.dll \
    INSTALL_SONAME=lua51.dll \
    TARGET_XSHLDFLAGS="-shared -Wl,--out-implib,liblua.dll.a" \
    INSTALL_SOSHORT1=liblua.dll.a \
    > ../make.log 2>&1
mv $3/bin/luajit.tmp $3/bin/luajit.exe
sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
