 #!/bin/bash
    #cronia varten mysqldump skripti

    # modaa setuppia varten // tee oma käyttäjä backuppia varten ja anna oikeudet haluttuihin kantoihin. Ei kannata ajaa roottina
    # variablet mysql loginia varten
    export DB_BACKUP=/home/mysql_backup
    export DB_USER=backup
    export DB_PASSWD=testi123
    export DATE=`date +”%d%b”`
    export MYSQL=mysql
    export MYSQLDUMP=mysqldump

    echo "“mySQL_backup"
    echo "———————-"
    #rotate vanhat lokit pois, vanhin menemään ja sitten uudemmat vanhemman päälle
    echo "* Rotating backups…"
    rm -rf $DB_BACKUP/04
    mv $DB_BACKUP/03 $DB_BACKUP/04
    mv $DB_BACKUP/02 $DB_BACKUP/03
    mv $DB_BACKUP/01 $DB_BACKUP/02
    mkdir $DB_BACKUP/01

    #tehdään uusi dumppi // kannan kannattaa olla melko pieni tätä varten. Ajaa kaikki databaset erillisiin zippeihin
    cd $DB_BACKUP/ && cd $DB_BACKUP/01
    $MYSQL -u $DB_USER --password=$DB_PASSWD -Bse "show databases" |while read m; \
    do $MYSQLDUMP --single-transaction -u $DB_USER --password=$DB_PASSWD `echo $m` > `echo $m`.sql;done
    #voi myös käyttää zippiä, mutta tämä ilmeisesti nopeampi
    bzip2 *sql

    #tehdään loki ja tallennetaan temppiin
    echo "* Creating new backup…"
    echo "Backup done! `date`" > /tmp/mysqldump.log

    #Jos halutaan maililla raportti.. 
    # mail -s “mysqldump report” haluttu@mailiosote.com < /tmp/my_report.log
    echo "----------------------"
    echo "Done"
exit 0        
