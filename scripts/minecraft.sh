#!/usr/bin/bash
SERVER='10.1.1.203'
MCUSER='minecraft'
MCPATH='/var/games/minecraft'
BACKUPPATH='/mnt/backup/minecraft'

MCDIR=$1
MCCOMMAND=$2
MCSERVER="mc-${MCDIR}"

# error handling when a command fails
PS4='LINENO:'

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


