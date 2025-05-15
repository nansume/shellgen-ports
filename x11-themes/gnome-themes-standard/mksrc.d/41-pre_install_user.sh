test "X${USER}" != 'Xroot' || return 0

# bug (not POSIX compliant): find: unrecognized: -or
sed -e '/ find /s| -or | -o |' -i themes/HighContrast/icons/Makefile
