#! /bin/sh

. ../../common.sh

mkdir -p $3/share/fontconfig/conf.avail
cp \
    fontconfig/20-unhint-small-dejavu-sans-mono.conf \
    fontconfig/20-unhint-small-dejavu-sans.conf \
    fontconfig/20-unhint-small-dejavu-serif.conf \
    fontconfig/57-dejavu-sans-mono.conf \
    fontconfig/57-dejavu-sans.conf \
    fontconfig/57-dejavu-serif.conf \
    $3/share/fontconfig/conf.avail

mkdir -p $3/share/fonts
cp \
    ttf/DejaVuSerifCondensed-BoldItalic.ttf \
    ttf/DejaVuSerif-Bold.ttf \
    ttf/DejaVuSerif-Italic.ttf \
    ttf/DejaVuSansMono-Oblique.ttf \
    ttf/DejaVuSansCondensed-Oblique.ttf \
    ttf/DejaVuSans-Bold.ttf \
    ttf/DejaVuMathTeXGyre.ttf \
    ttf/DejaVuSansMono-BoldOblique.ttf \
    ttf/DejaVuSerifCondensed-Bold.ttf \
    ttf/DejaVuSans-Oblique.ttf \
    ttf/DejaVuSansMono.ttf \
    ttf/DejaVuSerif-BoldItalic.ttf \
    ttf/DejaVuSans-ExtraLight.ttf \
    ttf/DejaVuSerif.ttf \
    ttf/DejaVuSansCondensed.ttf \
    ttf/DejaVuSansCondensed-Bold.ttf \
    ttf/DejaVuSerifCondensed.ttf \
    ttf/DejaVuSerifCondensed-Italic.ttf \
    ttf/DejaVuSansCondensed-BoldOblique.ttf \
    ttf/DejaVuSans.ttf \
    ttf/DejaVuSans-BoldOblique.ttf \
    ttf/DejaVuSansMono-Bold.ttf \
    $3/share/fonts

sed -i -e "s|<dir>WINDOWSUSERFONTDIR</dir>|<dir>WINDOWSUSERFONTDIR</dir>\n\n\t<dir>$3/share/fonts</dir>|g" $3/etc/fonts/fonts.conf
