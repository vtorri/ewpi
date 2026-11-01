#! /bin/sh

. ../../common.sh

sed -i -e "s|add_subdirectory(tests)||g;s|add_subdirectory(doc)||g" CMakeLists.txt

ewpi_cmake "Unix Makefiles" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5
