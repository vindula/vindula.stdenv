#!/bin/bash

TAR="$(which tar)"
GZIP="$(which gzip)"
LOGFILE="/tmp/bk.log"
SESSION_LOG="/tmp/$$.log"

APPDIR="/opt/intranet/app/intranet /opt/intranet/frontend /opt/intranet/supervisor"
EXCLUDE="--exclude=*.log --exclude=*.pyc --exclude=*.lock --exclude=.sock --exclude=*.pid --exclude=*.vsm --exclude=/opt/intranet/app/intranet/vindula/var/blobstorage"

DATA="$(date +"%d-%m-%Y-%H:%M")"

DEST="/opt/intranet/backup/data/app"

HOSTNAME="$(hostname)"

clean(){
	if [ $(ls $DEST | wc -l) -ge 7 ]; then
		echo -e "\n$DATA Removendo Full Backups APP Antigos"
		find $DEST -mtime +7 -exec rm -rv {} \; 
	fi
}

backup(){
	APPFILE="$DEST/APP-Intranet.$DATA.tar.bz2"
	$TAR -jcf $APPFILE $EXCLUDE $APPDIR
	echo -e "\nCriado Backup $APPFILE "
	du -hs $APPFILE 
	clean
}

backup > $SESSION_LOG
/usr/bin/mail -s "Relatório backup APP $HOSTNAME" "user@mail.com" < $SESSION_LOG
cat $SESSION_LOG >> $LOGFILE && rm $SESSION_LOG
