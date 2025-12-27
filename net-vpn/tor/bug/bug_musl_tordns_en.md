BUG: server can't find sample.test: NXDOMAIN from tordns (tor-0.4.8.14, musl-1.2.5)

========================================================================
nslookup sample.test
Server:         0.0.0.0
Address:        0.0.0.0:53

** server can't find sample.test: NXDOMAIN
========================================================================

# inter169/musl-nx: temporary repo for fixing musl codes -- nxdomain fix
https://github.com/inter169/musl-nx
------------------------------------------------------------------------
# LDAP DNS resolution fails in NextCloud AIO due to musl libc NXDOMAIN behavior on AAAA
https://github.com/nextcloud/all-in-one/discussions/6449
------------------------------------------------------------------------
# musl - Re: [PATCH 1/1] improve DNS resolution logic for parallel queries
https://www.openwall.com/lists/musl/2024/06/23/2
------------------------------------------------------------------------
https://stackoverflow.com/questions/65181012/does-alpine-have-known-dns-issue-within-kubernetes
------------------------------------------------------------------------
https://lite.duckduckgo.com/lite?q=musl+NXDOMAIN+fix&kl=us-en
------------------------------------------------------------------------