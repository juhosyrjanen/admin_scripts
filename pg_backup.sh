#postgresql dump and rotate script

#!/bin/bash

# insert into crontab:
# 01 22 * * * postgres /usr/local/sbin/db_backup.sh
# chmod 750 /usr/local/sbin/db_backup.sh
# chown root:postgres /usr/local/sbin/db_backup.sh
# mkdir -p /var/db_backup
# chown root:postgres /var/db_backup
# chmod 770 /var/db_backup


DIR=/var/db_backup
[ ! $DIR ] && mkdir -p $DIR || :
LIST=$(psql -l -t | cut -d\| -f2 | sed -e 's/ //g' | grep -v '^$' | grep -v template)
DATE=`date +%w`
for d in $LIST
do
  pg_dump $d | gzip -c >  $DIR/$d.$DATE.sql.gz
done

#log rotate                                                                              
for del in $(find /var/db_backup -name '*.sql.gz' -mmin +3000)
do
echo This directory is more than one day old and it is being removed: $del
rm $del
done                                                                      