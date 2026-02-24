PV=${PV#*-}

export am_cv_python_pyexecdir
am_cv_python_pyexecdir="${PYTHON_EXEC_PREFIX%/}/$(get_libdir)/python${PYTHON_VER}/site-packages"

if test -x "/bin/python"; then
  MYCONF="${MYCONF} --with-python=/bin/python"
else
  MYCONF="${MYCONF} --with-python=no"
fi
