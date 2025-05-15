if test -x "/bin/python"; then
  MYCONF="${MYCONF} --with-python=/bin/python"
else
  MYCONF="${MYCONF} --with-python=no"
fi
