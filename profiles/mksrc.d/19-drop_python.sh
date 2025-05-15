#export PYTHON_DISABLE_SSL=1
local BIN

for BIN in 'python' 'python3' 'python2'; do test -x "/bin/${BIN}" && return; done

export PYTHON='true'
