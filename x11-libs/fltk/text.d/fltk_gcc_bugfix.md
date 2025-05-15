# Macro Redefined Warning - Stack Overflow
# https://stackoverflow.com/questions/41793355/macro-redefined-warning

# suppress gcc warnings : "warning: this is the location of the previous definition" - Stack Overflow
# stackoverflow.com/questions/766964/suppress-gcc-warnings-warning-this-is-the-location-of-the-previous-definitio

CXXFLAGS+=' -std=gnu++11 -Wno-builtin-macro-redefined -Wno-parentheses -Wno-misleading-indentation'
CXXFLAGS+=' -Wno-format-truncation'
CXXFLAGS+=' -Wno-unused-result -Wno-char-subscripts'