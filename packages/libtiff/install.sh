#! /bin/sh

. ../../common.sh

ewpi_cmake "Ninja" \
    -DBUILD_SHARED_LIBS=ON \
    -DJPEG_INCLUDE_DIR=$3/include \
    -DLIBLZMA_INCLUDE_DIR=$3/include \
    -DWebP_INCLUDE_DIR=$3/include \
    -DZLIB_INCLUDE_DIR=$3/include \
    -DZSTD_INCLUDE_DIR=$3/include \
    -Djbig=FALSE \
    -Dlzma=TRUE \
    -Dwebp=TRUE \
    -Dcxx=FALSE \
    -Dtiff-tools=OFF \
    -Dtiff-tools-unsupported=OFF \
    -Dtiff-tests=OFF \
    -Dtiff-contrib=OFF \
    -Dtiff-docs=OFF \
    -Dtiff-deprecated=OFF
