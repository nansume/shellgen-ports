###################################################################################################################
# gpm cannot distinguish between Russian and English "a" if a font is terminus unicode bold with console-cyrillic #
###################################################################################################################
 Steps to reproduce:
 * Install gpm and console-cyrillic
 * Configure console-cyrillic and choose terminus unicode bold as a font
 * Restart console-cyrillic
 * Type Russian letters "a" and "o" (which look exactly same as English "a" and "o")
 * Copy them to clipboard using gpm
 * Paste

 What I get:
 * I get English "a" and "o" and "g"

 What I expected to get:
 * Russian "a" and "o" and "g"

 This bug is really bad. In the past, I didn't notice the bug and happily copied-and-pasted my Russian text from one text file to another.
 This introduced a lot of words with mixed Russian and English letters such as "?????". But one day I noticed that two files look exactly same,
 but "diff" says they are different. And then I finally understand that there is such bug, and my files are full of such words with mixed letters.

 This bug doesn't reproduce if I use unicyr font.
===================================================================================================================
https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=769748
===================================================================================================================