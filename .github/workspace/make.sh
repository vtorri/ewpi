set -euo pipefail
gcc -O2 -std=c99 -o ewpi ewpi*.c
./ewpi --verbose --strip --nsis --efl