#! /bin/sh

. ../../common.sh

git fetch && git fetch --tags
git checkout 05dad9298d2017e8a90cbbdf05b1ce88b2ef2c74

cp ../cross_toolchain.txt .

if test "x$4" = "xx86_64-w64-mingw32" ; then
    proc="AMD64"
    machine=-m64
else
    proc="X86"
    machine=-m32
fi

# cmake must burn in hell
sed -i -e "s|VMAF REQUIRED|VMAF|g" CMakeLists.txt
sed -i -e "s|add_library(aom_static STATIC \${AOM_SOURCES} \$<TARGET_OBJECTS:aom_rtcd>)||g" CMakeLists.txt
sed -i -e "s|set_target_properties(aom_static PROPERTIES OUTPUT_NAME aom)||g" CMakeLists.txt
sed -i -e "s|target_link_libraries(aom_static \${AOM_LIB_LINK_TYPE} m)||g" CMakeLists.txt
sed -i -e "s|set(AOM_LIB_TARGETS \${AOM_LIB_TARGETS} aom_static)||g" CMakeLists.txt
sed -i -e "s|set_target_properties(aom_static PROPERTIES LINKER_LANGUAGE CXX)||g" CMakeLists.txt
sed -i -e "s|target_link_libraries(aom_static \${AOM_LIB_LINK_TYPE} Threads::Threads)||g" CMakeLists.txt

sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_dsp_common>)||g" aom_dsp/aom_dsp.cmake
sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_dsp_decoder>)||g" aom_dsp/aom_dsp.cmake
sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_dsp_encoder>)||g" aom_dsp/aom_dsp.cmake
sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_dsp>)||g" aom_dsp/aom_dsp.cmake

sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:\${target_name}>)||g" build/cmake/aom_optimization.cmake
sed -i -e "s|target_sources(aom_static PRIVATE \"\${asm_object}\")||g" build/cmake/aom_optimization.cmake

sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_mem>)||g" aom_mem/aom_mem.cmake

sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_util>)||g" aom_util/aom_util.cmake

sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_scale>)||g" aom_scale/aom_scale.cmake

sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_av1_common>)||g" av1/av1.cmake
sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_av1_decoder>)||g" av1/av1.cmake
sed -i -e "s|target_sources(aom_static PRIVATE \$<TARGET_OBJECTS:aom_av1_encoder>)||g" av1/av1.cmake

sed -i -e "s|set(AOM_INSTALL_LIBS aom aom_static)||g" build/cmake/aom_install.cmake

#sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g;s|@prefix@|$prefix_unix|g" cross_toolchain.txt
sed -i -e "s|@host@|$4|g;s|@proc@|$proc|g" cross_toolchain.txt

rm -rf builddir && mkdir builddir && cd builddir

cmake \
    -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
    -DCMAKE_INSTALL_PREFIX=$prefix_unix \
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=$verbcmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O2 -pipe $machine -march=$1 -I$3/include/libvmaf -D__USE_MINGW_ANSI_STDIO=0" \
    -DCMAKE_EXE_LINKER_FLAGS="-s" \
    -DCMAKE_SHARED_LINKER_FLAGS="-s $machine" \
    -DBUILD_SHARED_LIBS=TRUE \
    -DCONFIG_AV1_DECODER=1 \
    -DCONFIG_AV1_ENCODER=1 \
    -DCONFIG_MULTITHREAD=1 \
    -DCONFIG_TUNE_VMAF=1 \
    -DENABLE_DOCS=FALSE \
    -DENABLE_EXAMPLES=FALSE \
    -DENABLE_TESTS=FALSE \
    -DENABLE_TOOLS=FALSE \
    -G "Unix Makefiles" \
    .. > ../../config.log 2>&1

# cmake must burn in hell
sed -i -e "s|-lm|-L$3/lib -lvmaf -lm|g" CMakeFiles/aom.dir/linklibs.rsp
#sed -i -e "s|I$prefix_unix|I|g" CMakeFiles/aom.dir/includes_C.rsp
#sed -i -e "s|I$prefix_unix|I|g" CMakeFiles/aom_dsp.dir/includes_C.rsp

make -j $jobopt install > ../../make.log 2>&1
