/bin/install -c -m 644 rxvt.7.man    /install//share/man/man7/urxvt.7
/bin/install -c -m 644 rclock.1.man  /install//share/man/man1/urclock.1
/bin/tic -x ./etc/rxvt-unicode.terminfo || \
           /bin/tic ./etc/rxvt-unicode.terminfo
"./etc/rxvt-unicode.terminfo", line 189, terminal 'rxvt-unicode-256color': //.terminfo: permission denied (errno 13)
"./etc/rxvt-unicode.terminfo", line 57, col 20, terminal 'rxvt-unicode': unknown capability 'kDC5'
"./etc/rxvt-unicode.terminfo", line 58, col 19, terminal 'rxvt-unicode': unknown capability 'kDC6'
"./etc/rxvt-unicode.terminfo", line 59, col 17, terminal 'rxvt-unicode': unknown capability 'kDN'
"./etc/rxvt-unicode.terminfo", line 60, col 18, terminal 'rxvt-unicode': unknown capability 'kDN5'
"./etc/rxvt-unicode.terminfo", line 62, col 20, terminal 'rxvt-unicode': unknown capability 'kIC5'
"./etc/rxvt-unicode.terminfo", line 63, col 19, terminal 'rxvt-unicode': unknown capability 'kIC6'
"./etc/rxvt-unicode.terminfo", line 65, col 21, terminal 'rxvt-unicode': unknown capability 'kEND5'
"./etc/rxvt-unicode.terminfo", line 66, col 20, terminal 'rxvt-unicode': unknown capability 'kEND6'
"./etc/rxvt-unicode.terminfo", line 68, col 21, terminal 'rxvt-unicode': unknown capability 'kFND5'
"./etc/rxvt-unicode.terminfo", line 69, col 20, terminal 'rxvt-unicode': unknown capability 'kFND6'
"./etc/rxvt-unicode.terminfo", line 71, col 21, terminal 'rxvt-unicode': unknown capability 'kHOM5'
"./etc/rxvt-unicode.terminfo", line 72, col 20, terminal 'rxvt-unicode': unknown capability 'kHOM6'
"./etc/rxvt-unicode.terminfo", line 74, col 19, terminal 'rxvt-unicode': unknown capability 'kLFT5'
"./etc/rxvt-unicode.terminfo", line 76, col 21, terminal 'rxvt-unicode': unknown capability 'kNXT5'
"./etc/rxvt-unicode.terminfo", line 77, col 20, terminal 'rxvt-unicode': unknown capability 'kNXT6'
"./etc/rxvt-unicode.terminfo", line 79, col 21, terminal 'rxvt-unicode': unknown capability 'kPRV5'
"./etc/rxvt-unicode.terminfo", line 80, col 20, terminal 'rxvt-unicode': unknown capability 'kPRV6'
"./etc/rxvt-unicode.terminfo", line 82, col 19, terminal 'rxvt-unicode': unknown capability 'kRIT5'
"./etc/rxvt-unicode.terminfo", line 83, col 17, terminal 'rxvt-unicode': unknown capability 'kUP'
"./etc/rxvt-unicode.terminfo", line 84, col 18, terminal 'rxvt-unicode': unknown capability 'kUP5'
"./etc/rxvt-unicode.terminfo", line 189, terminal 'rxvt-unicode-256color': //.terminfo: permission denied (errno 13)
make[1]: *** [Makefile:103: install] Error 1
make[1]: Leaving directory '/build/rxvt-unicode-src/doc'
make: *** [Makefile:37: install] Error 1