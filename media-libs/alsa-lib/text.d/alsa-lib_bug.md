# bug: generic HDA audio - no work
#  fix: remove /usr/share/alsa/pcm/dsnoop.conf
mv -n usr/share/alsa/pcm/dsnoop.conf usr/share/alsa/pcm/.dsnoop.conf

sed -i 's|^\(<confdir:pcm/dsnoop.conf>\)|#\1|' /usr/share/alsa/cards/aliases.conf


===================================================================================
##### alsa-lib_1.1.8
===================================================================================
[AO_ALSA] alsa-lib: src/conf.c:823:(get_char_skip_comments) Cannot access file /usr/share/alsa/pcm/front.conf
[AO_ALSA] alsa-lib: src/conf.c:1887:(_snd_config_load_with_include) _toplevel_:5:24:No such file or directory
[AO_ALSA] alsa-lib: src/conf.c:3650:(config_file_open) /usr/share/alsa/cards/HDA-Intel.conf may be old or corrupted: consider to remove or fix it
[AO_ALSA] alsa-lib: src/conf.c:3572:(snd_config_hooks_call) function snd_config_hook_load_for_all_cards returned error: No such file or directory