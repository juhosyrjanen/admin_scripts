 #!/bin/bash
    #myslqdump script for cron.daily

    # modaa setuppia varten // tee oma käyttäjä backuppia varten ja anna oikeudet haluttuihin kantoihin. Ei kannata ajaa roottina
    # variablet mysql loginia varten
    export DB_BACKUP=/home/mysql_backup
    export DB_USER=backup
    export DB_PASSWD=testi123
    export MYSQL=mysql
    export MYSQLDUMP=mysqldump
    export DATE=`date +”%d%b”`

    echo "“MySQL_backup"
    echo "———————-"
    #rotate vanhat lokit pois, vanhin menemään ja sitten uudemmat vanhemman päälle
    echo "* Rotating backups…"
    rm -rf $DB_BACKUP/04
    mv $DB_BACKUP/03 $DB_BACKUP/04 2>/dev/null
    mv $DB_BACKUP/02 $DB_BACKUP/03 2>/dev/null
    mv $DB_BACKUP/01 $DB_BACKUP/02
    mkdir $DB_BACKUP/01

    #tehdään uusi dumppi // Ajaa kaikki databaset erillisiin zippeihin
    cd $DB_BACKUP/01
    $MYSQL -u $DB_USER --password=$DB_PASSWD -Bse "show databases" |while read m; \
    do $MYSQLDUMP --single-transaction -u $DB_USER --password=$DB_PASSWD $m > $m.sql;done
    #voi myös käyttää zippiä, mutta tämä ilmeisesti nopeampi
    bzip2 *sql

    #tehdään loki ja tallennetaan temppiin
    echo "* Creating new backup…"
    echo "Backup done! $(DATE)" > /tmp/mysqldump.log

    #Jos halutaan maililla raportti.. 
    # mail -s “mysqldump report” haluttu@mailiosote.com < /tmp/my_report.log
    echo "----------------------"
    echo "Done"
exit 0        
