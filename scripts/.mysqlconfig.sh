export MYSQL_DATABASE="gedetra"
export MYSQL_USER="gedetrauser"
export MYSQL_PASSWORD="gedetrapass"
export MYSQL_ROOT_PASSWORD="gedetraroot"
export MYSQLPORT="3306"

if [ -d /run/mysqld ]; then
    echo "MySQL directory already present, skipping creation."
  else
    echo "MySQL data directory not found, creating initial DB."
    cat > /app/my.cnf <<!
        [mysqld]
        user    = root
        datadir = /run/mysqld
        port    = $MYSQLPORT
        skip-host-cache
!

    yes | cp -i /app/my.cnf /etc/mysql/my.cnf

    mkdir -p /run/mysqld
    mysql_install_db --user=root > /dev/null

    cat > create_db.sql <<!
      USE mysql;
      FLUSH PRIVILEGES;
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
      GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
      GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;
      GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
      CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;
      FLUSH PRIVILEGES;
!
    mysqld --user=root --bootstrap --verbose=0 < create_db.sql && \
    rm -f create_db.sql
    rm -f my.cnf
fi

echo "===================================="
echo "=         Runing MySQL             ="
echo "===================================="
exec /usr/bin/mysqld --user=root --console
echo "===================================="
