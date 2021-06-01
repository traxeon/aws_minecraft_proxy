#!/usr/bin/bash

# This code works with the systemd startup that accompanies the script.
# The mc-  prefix pre-pends the directory to identify the 'screen' process
# The ts command is used on echo statements to pre-pend the time stamp.  The command must be installed on the system.

SERVER='<server_ip>'
MCUSER='<daemon_owner>'
MCPATH='/var/games/minecraft'
BACKUPPATH='/mnt/backup/minecraft'

# Path for the directory of the server
MCDIR=$1
# Command to execute
MCCOMMAND=$2
# Identifier for the screen process
MCSERVER="mc-${MCDIR}"

# error handling when a command fails - line number display
PS4='LINENO:'

# verify that all variables were provided
if [[ -z $1 || -z $2 ]]; then
	echo "Incorrect syntax provided" | ts
	echo "Proper syntax: <script> <mcdir> <mccommand>" | ts
	exit 1
fi

mcsaveoff(){
	if pgrep --full ${MCSERVER} > /dev/null
	then
	  echo "${MCSERVER}: Active. Suspending saves" | ts
	  screen -p 0 -S ${MCSERVER} -X eval 'stuff "say Disabling saves"\015'
	  screen -p 0 -S ${MCSERVER} -X eval 'stuff \"save-all\"\015'
          screen -p 0 -S ${MCSERVER} -X eval 'stuff \"save-off\"\015'
	  sync
	  sleep 10
	else
	  echo "${MCSERVER}: Inactive. Not suspending saves." | ts
	  exit 1
	fi
}

mcsaveon(){
        if pgrep --full ${MCSERVER} > /dev/null
        then
          echo "${MCSERVER}: Active. Enabling saves" | ts
          screen -p 0 -S ${MCSERVER} -X eval 'stuff "say Enabling saves"\015'
          screen -p 0 -S ${MCSERVER} -X eval 'stuff \"save-on\"\015'
          screen -p 0 -S ${MCSERVER} -X eval 'stuff \"save-all\"\015'
          sync
          sleep 10
        else
          echo " ${MCSERVER}: Inactive. Not activting saves." | ts
	  exit 1
        fi
}

mcbackup(){
        if pgrep --full ${MCSERVER} > /dev/null
        then
          echo "${MCSERVER}: Activating Backup Job" | ts
	  screen -p 0 -S ${MCSERVER} -X eval 'stuff "say Backup job beginning"\015'
	  if [ ! -d ${BACKUPPATH}/${MCDIR} ]; then
            echo "${MCSERVER}: Create backup target path" | ts
            mkdir -p ${BACKUPPATH}/${MCDIR}
          fi
	  mcsaveoff
          NOW=`date "+%Y-%m-%d_%Hh%M"`  
	  BACKUP_FILE=${BACKUPPATH}/${MCDIR}/${MCSERVER}_${NOW}.tar 
	  echo "${MCSERVER}: Backing up server" | ts
	  tar -cf ${BACKUP_FILE} ${MCPATH}/${MCDIR}
	  mcsaveon
          screen -p 0 -S ${MCSERVER} -X eval 'stuff "say Backup job completed"\015'
          echo "${MCSERVER}: Compressing backup" | ts
	  gzip -f ${BACKUP_FILE}
	  echo "${MCSERVER}: Backup complete" | ts
        else
          echo "${MCSERVER}: Inactive. Not running backup." | ts
	  exit 1
        fi
}


case $2 in
  saveoff)
    mcsaveoff
    ;;
  saveon)
    mcsaveon
    ;;
  backup)
    mcbackup
    ;;
  *)
    echo "Invalid command: $2" | ts
    exit 1
    ;;

esac

exit 0


