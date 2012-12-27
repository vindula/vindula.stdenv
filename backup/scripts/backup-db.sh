#!/bin/bash

SQLUSER="backup"
SQLPASS="backup"
DBS="myvindulaDB openfire vindula_relstorageDB"
LOGFILE="/tmp/bk.log"
SESSION_LOG="/tmp/$$.log"

MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"

DATA="$(date +"%d-%m-%Y-%H:%M")"
MES="$(date +"%m-%Y")"

DEST="/opt/intranet/backup/data/db"

HOSTNAME="$(hostname)"

clean(){
	if [ $(ls $DEST | wc -l) -ge 21 ]; then
        	echo -e "\n$DATA Removendo Backups Antigos MySQL"
		find $DEST -mtime +7 -exec rm -rv {} \; 
	fi
}

backup(){

for DB in $DBS; do
        FILE="$DEST/$DB.$HOSTNAME.$DATA.sql.gz"
        $MYSQLDUMP --max_allowed_packet=128M -u $SQLUSER -p$SQLPASS -B $DB --single-transaction | $GZIP -c > $FILE
        echo -e "\nCriado Backup MySQL $DB $DATA "
        du -hs $FILE
done
	clean
}

backup > $SESSION_LOG
/usr/bin/mail -s "Relatório backup MySQL $HOSTNAME" "user@mail.com" < $SESSION_LOG
cat $SESSION_LOG >> $LOGFILE && rm $SESSION_LOG
