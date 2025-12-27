==================================================================================================================
net-irc/weechat-4.1.0 - undefined reference to symbol 'cbreak'
==================================================================================================================
      |                            ~~~~~~~~~~~~~~
  381 |                            client_proof_base64);
      |                            ~~~~~~~~~~~~~~~~~~~~
/build/weechat-src/src/plugins/irc/irc-sasl.c:166:56: warning: 'snprintf' output may be truncated before the last format character [-Wformat-truncation=]
  166 |             snprintf (string, length + 1, "n,,n=%s,r=%s",
      |                                                        ^
/build/weechat-src/src/plugins/irc/irc-sasl.c:166:13: note: 'snprintf' output 9 or more bytes (assuming 34) into a destination of size 33
  166 |             snprintf (string, length + 1, "n,,n=%s,r=%s",
      |             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  167 |                       username2, nonce_client_base64);
      |                       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/bin/ld: libweechat_gui_curses_normal.a(gui-curses-main.c.o): undefined reference to symbol 'cbreak'
/bin/ld: /libx32/libtinfow.so.6: error adding symbols: DSO missing from command line
collect2: error: ld returned 1 exit status
make[2]: *** [src/gui/curses/normal/CMakeFiles/weechat.dir/build.make:109: src/gui/curses/normal/weechat] Error 1
make[1]: *** [CMakeFiles/Makefile2:1129: src/gui/curses/normal/CMakeFiles/weechat.dir/all] Error 2
make[1]: *** Waiting for unfinished jobs....
[ 96%] Building C object src/plugins/irc/CMakeFiles/irc.dir/irc-tag.c.o
/build/weechat-src/src/plugins/irc/irc-sasl.c: In function 'irc_sasl_mechanism_ecdsa_nist256p_challenge':
/build/weechat-src/src/plugins/irc/irc-sasl.c:556:47: warning: '%s' directive output may be truncated writing likely 1 or more bytes into a region of size between 0 and 1 [-Wformat-truncation=]
  556 |             snprintf (string, length + 1, "%s|%s", sasl_username, sasl_username);
      |                                               ^~
/build/weechat-src/src/plugins/irc/irc-sasl.c:556:43: note: assuming directive output of 1 byte
  556 |             snprintf (string, length + 1, "%s|%s", sasl_username, sasl_username);
==================================================================================================================