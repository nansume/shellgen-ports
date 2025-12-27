python-3.12.10 - err build
----------------------------------------------------------------------
./_bootstrap_python ./Programs/_freeze_module.py _collections_abc ./Lib/_collections_abc.py Python/frozen_modules/_collections_abc.h
Fatal Python error: init_import_site: Failed to import the site module
Python runtime state: initialized
Traceback (most recent call last):
  File "/build/Python-3.12.10/Lib/site.py", line 80, in <module>
    PREFIXES = [sys.prefix, sys.exec_prefix]
                ^^^^^^^^^^
AttributeError: module 'sys' has no attribute 'prefix'
Fatal Python error: init_import_site: Failed to import the site module
Python runtime state: initialized
Traceback (most recent call last):
  File "/build/Python-3.12.10/Lib/site.py", line 80, in <module>
make[2]: *** [Makefile:1337: Python/frozen_modules/io.h] Error 1
make[2]: *** Waiting for unfinished jobs....
    PREFIXES = [sys.prefix, sys.exec_prefix]
                ^^^^^^^^^^
AttributeError: module 'sys' has no attribute 'prefix'
make[2]: *** [Makefile:1334: Python/frozen_modules/codecs.h] Error 1
Fatal Python error: init_import_site: Failed to import the site module
Python runtime state: initialized
Traceback (most recent call last):
  File "/build/Python-3.12.10/Lib/site.py", line 80, in <module>
    PREFIXES = [sys.prefix, sys.exec_prefix]
                ^^^^^^^^^^
AttributeError: module 'sys' has no attribute 'prefix'
make[2]: *** [Makefile:1331: Python/frozen_modules/abc.h] Error 1
Fatal Python error: init_import_site: Failed to import the site module
Python runtime state: initialized
Traceback (most recent call last):
  File "/build/Python-3.12.10/Lib/site.py", line 80, in <module>
    PREFIXES = [sys.prefix, sys.exec_prefix]
                ^^^^^^^^^^
AttributeError: module 'sys' has no attribute 'prefix'
make[2]: *** [Makefile:1340: Python/frozen_modules/_collections_abc.h] Error 1
make[2]: Leaving directory '/build/Python-3.12.10'
make[1]: *** [Makefile:799: profile-gen-stamp] Error 2
make[1]: Leaving directory '/build/Python-3.12.10'
make: *** [Makefile:811: profile-run-stamp] Error 2
-------------------------------------------------------------------------------
Failed make build
Failed package build from user... error