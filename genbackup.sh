#!/bin/bash

# set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/backups"
MYSQLPERMS="-uroot -p$MYSQL_ROOT_PASSWORD"
MYSQL="mysql $MYSQLPERMS "
MYSQLDUMP="mysqldump $MYSQLPERMS "

function backupSchema() {
        DB=$1
        DEST=$2
        mkdir -p $DEST
        chmod 777 $DEST
        $MYSQLDUMP $DB --all-tablespaces --no-data > $DIR/$DB.sql
}

function getTables() {
        DB=$1
        echo $($MYSQL $DB -Be 'show tables' | awk 'NR>1')
}

function backupTable() {
        DB=$1
        TABLE=$2
        OUTFILE=$3
        rm -f $OUTFILE
        $MYSQL $DB -Be "select * from $TABLE into OUTFILE '$OUTFILE'"
}

DBS=$($MYSQL -Be 'show databases' | awk 'NR>1 && ! /^_/')

for db in $DBS; do
        [ "$db" == "information_schema" -o "$db" == "performance_schema" ] && continue
        DEST="$DIR/$db"
        echo Backing up Database $db to $DEST
        backupSchema $db $DEST
        TABLES=$(getTables $db)
        for table in $TABLES; do
                OUTFILE=$DEST/$table.dump
                echo -n "$table .. "
                backupTable $db $table $OUTFILE
                echo -n "Done. "
        done
        echo ""
done

