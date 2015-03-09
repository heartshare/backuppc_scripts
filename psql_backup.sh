#! /bin/bash
DAILYLOGFILE="/var/log/psql_backup.daily.log"
rm "$DAILYLOGFILE"
/usr/bin/touch "$DAILYLOGFILE"
/bin/chown backuppc:backuppc "$DAILYLOGFILE"
/bin/chmod 777 "$DAILYLOGFILE"

EMAIL="support@vip-consult.co.uk"

BACKUP_DIR="$1/$2/$3"
SERVER=$2
CONTAINER=$3

run_message="Please run using /script_name backup_dir server_ip container_name"

if [ -z "$SERVER" ] || [ -z "$BACKUP_DIR" ] || [ -z "$CONTAINER" ]  ; then
        echo $run_message;
        exit
fi

echo -e "Starting Psql Docker backup conatiner with backup folder:$BACKUP_DIR , container:$CONTAINER , server: $SERVER ! \n"
/usr/bin/ssh  -x -l vipconsult $SERVER \
sudo docker run --rm --link $CONTAINER:$CONTAINER \
-v $BACKUP_DIR:$BACKUP_DIR \
-e backup_dir=$BACKUP_DIR \
-e backup_container=$CONTAINER \
  vipconsult/psql_backup \
  2>  >(/usr/bin/tee -a ${DAILYLOGFILE} >&2)


if [ -s $DAILYLOGFILE ]; then    #email only if error ocured - ie log file exists
    cat "$DAILYLOGFILE" | /usr/bin/mail -s "Servers Backup Log" $EMAIL -aFrom:backuppc@vip-consult.co.uk

    if [[ $? -ne 0 ]]; then
        echo -e "ERROR:  Error log  could not be emailed to you! \n";
        else
        echo -e "Backup Error log has been emailed to $EMAIL ! \n"
    fi
fi
