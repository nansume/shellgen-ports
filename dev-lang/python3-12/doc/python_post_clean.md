# python - Python3 project remove __pycache__ folders and .pyc files - Stack Overflow
[https://stackoverflow.com/questions/28991015/python3-project-remove-pycache-folders-and-pyc-file]
`find . -regex '^.*\(__pycache__\|\.py[co]\)$' -delete`
`find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf`