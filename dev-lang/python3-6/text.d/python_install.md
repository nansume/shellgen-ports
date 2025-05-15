# setuptools - Python setup.py develop vs install - Stack Overflow
[https://stackoverflow.com/questions/19048732/python-setup-py-develop-vs-install]
`setup.py` - direct local filesystem
`pip install -e PATH` (within a virtualenv)

# python - How to use setuptools to install in a custom directory?
https://stackoverflow.com/questions/24745852/how-to-use-setuptools-to-install-in-a-custom-directory

# Installing Python Modules - Python 3.11.3 documentation
[https://docs.python.org/3/installing/index.html]
`python -m pip install "SomePackage>=1.0.4"`  # minimum version
`python -m pip install --upgrade SomePackage`
# pip install <home> dir
pip install --user `fonttools`
# install pip
python -m ensurepip --default-pip

# use install
easy_install `package`  # python-setuptools in content it

========================================================================================================
####  Here's a breakdown of the important differences between pip and the deprecated easy_install:  ####
========================================================================================================

                                 pip                                               easy_install
* Installs from Wheels           [Yes]                                               [No]
* Uninstall Packages             [Yes] (python -m pip uninstall)                     [No]
* Dependency Overrides           [Yes] (Requirements Files)                          [No]
* List Installed Packages        [Yes] (python -m pip list and python -m pip freeze) [No]
* PEP 438 Support                [Yes]                                               [No]
* Installation format            [Flat] packages with egg-info metadata.             [Encapsulated Egg format]
* sys.path modification          [No]                                                [Yes]
* Installs from Eggs             [No]                                                [Yes]
* pylauncher support             [No]                                                [Yes] 1
* Multi-version installs         [No]                                                [Yes]
* Exclude scripts during install [No]                                                [Yes]
* per project index              [Only in virtualenv]                                [Yes], via setup.cfg
=========================================================================================================