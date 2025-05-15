###############################################################
####  sys-boot/grub-2.02 + grub-add-f2fs-support-v8.patch  ####
###############################################################
configure.ac:48: error: version mismatch.  This is Automake 1.15.1,
configure.ac:48: but the definition used by this AM_INIT_AUTOMAKE
configure.ac:48: comes from Automake 1.15.  You should recreate
configure.ac:48: aclocal.m4 with aclocal and run automake again.
WARNING: 'automake-1.15' is probably too old.
         You should only need it if you modified 'Makefile.am' or
         'configure.ac' or m4 files included by 'configure.ac'.
         The 'automake' program is part of the GNU Automake package:
         <http://www.gnu.org/software/automake>
         It also requires GNU Autoconf, GNU m4 and Perl in order to run:
         <http://www.gnu.org/software/autoconf>
         <http://www.gnu.org/software/m4/>
         <http://www.perl.org/>
make: *** [Makefile:3137: Makefile.in] Error 63

# fix
autoreconf-2.69: configure.ac: AM_GNU_GETTEXT is used, but not AM_GNU_GETTEXT_VERSION

https://wiki.gentoo.org/wiki/Project:Quality_Assurance/Autotools_failures



#####################################################################
#####  grub2 [grub-install] - sh: dmidecode: command not found  #####
#####################################################################
sh: dmidecode: command not found
Information: You may need to update /etc/fstab.

sh: dmidecode: command not found
Information: You may need to update /etc/fstab.



=====================================================================
66277 - [regression] cpp-5: fatal error: too many input files
https://gcc.gnu.org/bugzilla/show_bug.cgi?id=66277

Comment 1 Jakub Jelinek  2015-05-25 08:21:43 UTC

Seems to be a user error.  Just read man page of cpp and gcc, the former accepts (besides options) just two arguments, infile and outfile, while grub clearly relies on $(CPP) being able to preprocess many source files at the same time.
That is gcc -E, not cpp (and if you don't override it from the command line, that is indeed what the configure will do correctly automatically).
Comment 2 Paul Menzel  2015-05-25 09:06:09 UTC

(In reply to Jakub Jelinek from comment #1)
> Seems to be a user error.  Just read man page of cpp and gcc, the former
> accepts (besides options) just two arguments, infile and outfile, while grub
> clearly relies on $(CPP) being able to preprocess many source files at the
> same time.
> That is gcc -E, not cpp (and if you don't override it from the command line,
> that is indeed what the configure will do correctly automatically).

Indeed! Thank you very much. `CC=gcc-5 ./configure` does not use `cpp-4.9` for `CPP` but `gcc-5 -E`. Quite confusing.

So it indeed not a bug and not a regression. I remember to not set `CPP` manually in the future. Sorry for the noise.


=====================================================================
grub-mkfont: Yes
grub-mount: No (need FUSE library)
starfield theme: No (No DejaVu found)
With libzfs support: No (need zfs library)
Build-time grub-mkfont: No (no fonts)
Without unifont (no build-time grub-mkfont)
With liblzma from -llzma (support for XZ-compressed mips images)
With stack smashing protector: No
*******************************************************
./grub-core/script/parser.y:92.1-12: warning: deprecated directive: '%pure-parser', use '%define api.pure' [-Wdeprecated]
   92 | %pure-parser
      | ^~~~~~~~~~~~
      | %define api.pure
x86_64-pc-linux-gnux32-cpp: fatal error: too many input files
compilation terminated.
make: *** [Makefile:13316: grub_fstest.pp] Error 1
make: *** Waiting for unfinished jobs....
./grub-core/script/parser.y: warning: fix-its can be applied.  Rerun with option '--update'. [-Wother]
declare -x USER="root"
declare -- USE_BUILD_ROOT="0"
spkg ^[[33m--install^[[31m perl_5.34.0_x32.cxz^[[m... ^[[1;33mok^[[m
spkg ^[[33m--install^[[31m m4_1.4.19_x32.cxz^[[m... ^[[1;33mok^[[m
########################################################################



[build fix -- successful ok!]
========================================================================
config.status: creating po/Makefile
*******************************************************
GRUB2 will be compiled with following components:
Platform: i386-pc
With devmapper support: No (need libdevmapper header)
With memory debugging: No
With disk cache statistics: No
With boot time statistics: No
efiemu runtime: No (explicitly disabled)
grub-mkfont: Yes
grub-mount: No (need FUSE library)
starfield theme: No (No DejaVu found)
With libzfs support: No (need zfs library)
Build-time grub-mkfont: No (no fonts)
Without unifont (no build-time grub-mkfont)
With liblzma from -llzma (support for XZ-compressed mips images)
With stack smashing protector: No
*******************************************************
Configure directory: /build/grub-src/... ok
########################################################################

+ nice -n 19 make --jobs=4 --load-average=4 -s V=0 PREFIX=/ prefix=/ USRDIR=/ SHARED=yes LIBDIR=/libx32 -f Makefile
./grub-core/script/parser.y:92.1-12: warning: deprecated directive: '%pure-parser', use '%define api.pure' [-Wdeprecated]
   92 | %pure-parser
      | ^~~~~~~~~~~~
      | %define api.pure
./grub-core/script/parser.y: warning: fix-its can be applied.  Rerun with option '--update'. [-Wother]
Making all in grub-core/lib/gnulib
  GEN      alloca.h
  GEN      dirent.h
  GEN      fcntl.h
  GEN      getopt.h
  GEN      getopt-cdefs.h
  GEN      langinfo.h