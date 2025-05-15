####################
# iptables bug x32 #
####################

https://bugs.gentoo.org/show_bug.cgi?id=472388
iptables: x32/n32 ABIs: iptables -L: can't initialize iptables table `filter': Invalid argument
x_tables: ip_tables: ERROR.0 target: invalid size 32 (kernel) != (user) 30
-fpack-struct[=n] Without a value specified, pack all structure members together without holes. When a value is
specified (which must be a small power of two), pack structure members according to this value, representing the
maximum alignment (that is, objects with default alignment requirements larger than this are output potentially
unaligned at the next fitting location.
Warning: the -fpack-struct switch causes GCC to generate code that is not binary compatible with code generated
without that switch.
Additionally, it makes the code suboptimal. Use it to conform to a non-default application binary interface.
================================================================================================================


# no support - kernel xtables x32 abi
iptables

    bug: iptables
    abi: x32 (only)
    nowork!

# Hack around struct mismatches between userland & kernel for some ABIs. #472388
CFLAGS+=' -fpack-struct=4'
CXXFLAGS=$CFLAGS