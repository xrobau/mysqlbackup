#!/bin/bash

#set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/backups"
MYSQLPERMS="-uroot -p$MYSQL_ROOT_PASSWORD"
MYSQL="mysql $MYSQLPERMS "

function getDbs() {
        find $DIR -mindepth 1 -type d -print
}

DBS=$(getDbs)

for dbdir in $DBS; do
        DB=$(basename $dbdir)
        SQLFILE=$DIR/$DB.sql
        # Change dest db for testing
        DB=x$(basename $dbdir)
        echo Restoring $DB from $dbdir
        $MYSQL -Be "create database if not exists $DB"
        $MYSQL -B $DB < $SQLFILE
        for tablefile in $dbdir/*.dump; do
                TABLENAME=$(basename $tablefile | sed 's/.dump$//')
                echo -n "$TABLENAME .. "
                $MYSQL $DB -Be "load data infile '$tablefile' into table $DB.$TABLENAME"
		echo -n "Done. "
        done
	echo ""
done

