#!/bin/bash
set -e

echo "In mysqld.sh script";

# chown -R mysql:mysql /var/lib/mysql
mysql_install_db --user mysql > /dev/null

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-""}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}
MYSQL_USER=${MYSQL_USER:-""}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}
MYSQLD_ARGS=${MYSQLD_ARGS:-""}

tfile=`mktemp`
if [[ ! -f "$tfile" ]]; then
    return 1
fi

cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("$MYSQL_ROOT_PASSWORD") WHERE user='root';
EOF

if [[ $MYSQL_DATABASE != "" ]]; then
    echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile

    if [[ $MYSQL_USER != "" ]]; then
        echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $tfile
    fi
fi

if [[ $INNODB_POOL_BUFFER_SIZE ]]; then
    sed -i "s/innodb_buffer_pool_size=8M/innodb_buffer_pool_size=$INNODB_POOL_BUFFER_SIZE/g" /etc/mysql/conf.d/my.cnf
fi

if [[ $INNODB_LOG_FILE_SIZE ]]; then
    sed -i "s/innodb_log_file_size=10M/innodb_log_file_size=$INNODB_LOG_FILE_SIZE/g" /etc/mysql/conf.d/my.cnf
fi

if [[ $INNODB_LOG_BUFFER_SIZE ]]; then
    sed -i "s/innodb_log_buffer_size=10M/innodb_log_buffer_size=$INNODB_LOG_BUFFER_SIZE/g" /etc/mysql/conf.d/my.cnf
fi

if [[ $INNODB_FLUSH_LOG_AT_TRX_COMMIT ]]; then
    sed -i "s/innodb_flush_log_at_trx_commit=1/innodb_flush_log_at_trx_commit=$INNODB_FLUSH_LOG_AT_TRX_COMMIT/g" /etc/mysql/conf.d/my.cnf
fi

/usr/sbin/mysqld --bootstrap --verbose=0 $MYSQLD_ARGS < $tfile
rm -f $tfile

exec /usr/sbin/mysqld $MYSQLD_ARGS