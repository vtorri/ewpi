 * verify that everything is pushed and NEWS and PEADME.md are up to date
 * update version _ew_vmaj and _ew_vmin in ewpi.c
 * rm -rf $HOME/ewpi_64
 * ./ewpi --jobs=2
 * ./ewpi --jobs=2 --nsis
 * git tag v1.1 master
 * git push origin v1.1
 * https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository
 * git archive --output=./ewpi-vmaj.vmin.tar vvmaj.vmin
 * gzip -9 ewpi-vmaj.vmin.tar
 * git archive --output=./ewpi-vmaj.vmin.tar vvmaj.vmin
 * xz -9 ewpi-vmaj.vmin.tar
 * go to https://github.com/vtorri/ewpi/releases and click on the pen (top right) to edit
 * scroll down to attach the 2 files to the assets
