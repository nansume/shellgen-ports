rdiff-backup-2.2.6 - err build
-------------------------------------------------------------------------------
python3 -m flit_core.wheel
Traceback (most recent call last):
  File "/lib/python3.8/runpy.py", line 194, in _run_module_as_main
    return _run_code(code, main_globals, None,
  File "/lib/python3.8/runpy.py", line 87, in _run_code
    exec(code, run_globals)
  File "/lib/python3.8/site-packages/flit_core/wheel.py", line 260, in <module>
    main()
  File "/lib/python3.8/site-packages/flit_core/wheel.py", line 256, in main
    info = make_wheel_in(pyproj_toml, outdir)
  File "/lib/python3.8/site-packages/flit_core/wheel.py", line 223, in make_wheel_in
    wb = WheelBuilder.from_ini_path(ini_path, fp)
  File "/lib/python3.8/site-packages/flit_core/wheel.py", line 84, in from_ini_path
    ini_info = read_flit_config(ini_path)
  File "/lib/python3.8/site-packages/flit_core/config.py", line 78, in read_flit_config
    d = tomllib.loads(path.read_text('utf-8'))
  File "/lib/python3.8/pathlib.py", line 1236, in read_text
    with self.open(mode='r', encoding=encoding, errors=errors) as f:
  File "/lib/python3.8/pathlib.py", line 1222, in open
    return io.open(self, mode, buffering, encoding, errors, newline,
  File "/lib/python3.8/pathlib.py", line 1078, in _opener
    return self._accessor.open(self, flags, mode)
FileNotFoundError: [Errno 2] No such file or directory: '/build/rdiff-backup-2.2.6/pyproject.toml'
Building wheel from /build/rdiff-backup-2.2.6
-------------------------------------------------------------------------------
Failed make build