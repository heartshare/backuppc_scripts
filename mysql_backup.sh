#! /bin/bash
DAILYLOGFILE="/var/log/mysql_backup.daily.log"
rm "$DAILYLOGFILE"
/usr/bin/touch "$DAILYLOGFILE"
/bin/chown backuppc:backuppc "$DAILYLOGFILE"
/bin/chmod 777 "$DAILYLOGFILE"

EMAIL="support@vip-consult.co.uk"

SERVER=$1
CONTAINER=$2
BACKUP_DIR="/home/mysql_backup"

run_message="Please run using /script_name server_ip container_name backup_dir"

if [ -z "$SERVER" ] || [ -z "$BACKUP_DIR" ] || [ -z "$CONTAINER" ]  ; then
        echo $run_message;
        exit
fi

echo -e "Starting Mysql Docker backup conatiner with backup folder:$BACKUP_DIR , container:$CONTAINER , server: $SERVER ! \n"
/usr/bin/ssh  -x -l vipconsult $SERVER \
sudo docker run --rm --link $CONTAINER:$CONTAINER \
-v /home/mysql/.my.cnf:/root/.my.cnf \
-v /home/mysql_backup:/home/mysql_backup \
-e backup_dir=$BACKUP_DIR/$SERVER/$CONTAINER \
-e backup_server=$CONTAINER \
-e backup_host=$SERVER  vipconsult/mysql_backup \
  2>  >(/usr/bin/tee -a ${DAILYLOGFILE} >&2)


if [ -s $DAILYLOGFILE ]; then    #email only if error ocured - ie log file exists
    cat "$DAILYLOGFILE" | /usr/bin/mail -s "Servers Backup Log" $EMAIL -aFrom:backuppc@vip-consult.co.uk

    if [[ $? -ne 0 ]]; then
        echo -e "ERROR:  Error log  could not be emailed to you! \n";
        else
        echo -e "Backup Error log has been emailed to $EMAIL ! \n"
    fi
fi
