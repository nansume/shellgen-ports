####### python setup.py - hash md5 was not found  #######
declare -x PWD="/build/setuptools-src"
declare -- WORKDIR="/build/setuptools-src"
declare -x PYTHONPATH="/bin"
declare -x PYTHON="python2"
declare -x PYTHONPYCACHEPREFIX="/var/cache/python"
declare -x PYTHON_VER="2.7"
declare -x PYTHON_PREFIX="/"
declare -x PYTHON_EXEC_PREFIX="/"
declare -x HOME="/install"
declare -x PYTHONHOME="/:/"
declare -- PYTHON_XLIBS="/install/lib/python2.7/site-packages"
+ python setup.py install --root / --prefix /install --install-lib /install/lib/python2.7/site-packages
ERROR:root:code for hash md5 was not found.
Traceback (most recent call last):
  File "/lib/python2.7/hashlib.py", line 147, in <module>
    globals()[__func_name] = __get_hash(__func_name)
  File "/lib/python2.7/hashlib.py", line 97, in __get_builtin_constructor
    raise ValueError('unsupported hash type ' + name)
ValueError: unsupported hash type md5
ERROR:root:code for hash sha1 was not found.
Traceback (most recent call last):
  File "/lib/python2.7/hashlib.py", line 147, in <module>
    globals()[__func_name] = __get_hash(__func_name)
  File "/lib/python2.7/hashlib.py", line 97, in __get_builtin_constructor
    raise ValueError('unsupported hash type ' + name)
ValueError: unsupported hash type sha1
ERROR:root:code for hash sha224 was not found.
Traceback (most recent call last):
  File "/lib/python2.7/hashlib.py", line 147, in <module>
    globals()[__func_name] = __get_hash(__func_name)
  File "/lib/python2.7/hashlib.py", line 97, in __get_builtin_constructor
    raise ValueError('unsupported hash type ' + name)
ValueError: unsupported hash type sha224
ERROR:root:code for hash sha256 was not found.
Traceback (most recent call last):
  File "/lib/python2.7/hashlib.py", line 147, in <module>
    globals()[__func_name] = __get_hash(__func_name)
  File "/lib/python2.7/hashlib.py", line 97, in __get_builtin_constructor
    raise ValueError('unsupported hash type ' + name)
ValueError: unsupported hash type sha256
ERROR:root:code for hash sha384 was not found.
Traceback (most recent call last):
  File "/lib/python2.7/hashlib.py", line 147, in <module>
    globals()[__func_name] = __get_hash(__func_name)
  File "/lib/python2.7/hashlib.py", line 97, in __get_builtin_constructor
    raise ValueError('unsupported hash type ' + name)
ValueError: unsupported hash type sha384
ERROR:root:code for hash sha512 was not found.
Traceback (most recent call last):
  File "/lib/python2.7/hashlib.py", line 147, in <module>
    globals()[__func_name] = __get_hash(__func_name)
  File "/lib/python2.7/hashlib.py", line 97, in __get_builtin_constructor
    raise ValueError('unsupported hash type ' + name)
ValueError: unsupported hash type sha512
running install
running build
running build_py
##############################################################

probabilities <python2> build without hash md5, sha224, etc?