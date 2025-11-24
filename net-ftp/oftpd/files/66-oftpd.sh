#!/lib/shell/env bash5
# Copyright (C) 2019 Artem Slepnev, Shellgen
# License GPLv3+: GNU GPL version 3 or later
# gnu.org/licenses/gpl.html



_oftpd() {
   unset -f $FUNCNAME

   ! [[ ${PID-} ]] || return

   source /lib/shell/so net

   declare -ir MAX_CLIENT=2
   declare -ir FTP_LOG=0
   declare -r FTP_USER=ftp
   declare -r FTP_HOME=/home/ftp


   case ${1-} in
      start)
         oftpd --port $FTP_PORT --interface 2002:$IP6PREFIX::3 \
          --max-clients $MAX_CLIENT --local $FTP_LOG $FTP_USER $FTP_HOME
      ;;
      stop)
         #killall oftpd
         [[ ${PID:-} ]]
         kill -s SIGINT $PID
         [[ -f $PIDFILE ]] && rm $PIDFILE
      ;;
      *)
         return 1
      ;;
   esac
}