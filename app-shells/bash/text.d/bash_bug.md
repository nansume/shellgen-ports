==================================================================================
#####  bash: cannot set terminal process group (-1) inappropriate ioctl for device
#####  bash: no job control in this shell
==================================================================================

###  One of the possible options would be not having access to the tty.
===========================================================================================

Under the hood:
1. bash checks whether the session is interactive, if not - no job control.
2. if forced_interactive is set, then check that stderr is attached to a tty is skipped and bash checks again, whether in can open /dev/tty for read-write access.
3. then it checks whether new line discipline is used, if not, then job control is disabled too.
4. If (and only if) we just set our process group to our pid, thereby becoming a process group leader, and the terminal is not in the same process group as our (new) process group, then set the terminal's process group to our (new)
   process group. If that fails, set our process group back to what it was originally (so we can still read from the terminal) and turn off job control.
5. if all of the above has failed, you see the message.
===========================================================================================


###  I partially quoted the comments from bash source code.
===========================================================================================

As per additional request of the question author:
http://tiswww.case.edu/php/chet/bash/bashtop.html Here you can find bash itself.
If you can read the C code, get the source tarball, inside it you will find job.c - that one will explain you more "under the hood" stuff. :)
===========================================================================================

https://stackoverflow.com/questions/11821378/what-does-bashno-job-control-in-this-shell-mean
https://unix.stackexchange.com/questions/251202/bash-no-job-control-in-this-shell


###  bug: after logout through -t ${N} sec.
===========================================================================================

read -ren ${N} -t ${N} -p "${MESG}" -i "${IF}" -d "${IFS}" IF

# bug fix: after logout through -t ${N} sec.
    ((PPID&&!UID)) && [[ ${PS1-} ]] && trap exec bash --login EXIT
# or
    IF=$(read -ren ${N} -t ${N} -p "${MESG}" -i "${IF}" -d "${IFS}" IF && printf "${IF}") &&
===========================================================================================


# bug: call <return trap> 2 and such.
#_PRE_EXIT() { unset -f $FUNCNAME; [[ $STR ]] && declare -p STR;[[ -f $TMPFILE ]] && rm -- $TMPFILE;}

#trap printf ${ERRO/... / ${LINENO}&};[[ $EXIT ]] && $EXIT; printf tERR: ${EXIT:-null}\n ERR
#trap trap - RETURN ERR; printf tRETURN\n; declare -F _PRE_EXIT > /dev/null && _PRE_EXIT RETURN
#trap trap - RETURN ERR; declare -F _PRE_EXIT > /dev/null && _PRE_EXIT RETURN