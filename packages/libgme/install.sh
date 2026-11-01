#! /bin/sh

. ../../common.sh

sed -i -e "s|add_subdirectory(player|#add_subdirectory(player|g;s|add_subdirectory(demo|#add_subdirectory(demo|g" CMakeLists.txt

ewpi_cmake "Unix Makefiles" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DENABLE_UBSAN:BOOL=OFF
