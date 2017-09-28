#!/bin/sh
mkdir -p $mysql_data_dir
$mysql_base_dir/bin/mysqld --initialize-insecure --basedir=$mysql_base_dir --datadir=$mysql_data_dir
if id -u mysql >/dev/null 2>&1; then
    echo "user exists"
else
    echo "user does not exist, create it"
    useradd mysql -U
fi
chown -R mysql:mysql $mysql_data_dir

#mysqld_safe only know it
ln -s $mysql_base_dir /usr/local/mysql

echo "start it.... wait 10 sec..."
$mysql_base_dir/bin/mysqld_safe --defaults-file=./$mysql_cnf &

# wait to start
for i in {1..10}
do
    echo -e ".\c"
    sleep  1
done

$mysql_base_dir/bin/mysql -P$mysql_port  -S $mysql_sock -uroot  --skip-password -e " 
SET SQL_LOG_BIN=0;
CREATE USER 'admin'@'%' IDENTIFIED BY 'shurumima';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata.* TO admin@'%' WITH GRANT OPTION;
GRANT RELOAD, SHUTDOWN, PROCESS, FILE, SUPER, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO admin@'%' WITH GRANT OPTION;
GRANT SELECT ON performance_schema.* TO admin@'%' WITH GRANT OPTION;
GRANT SELECT ON sys.* TO admin@'%' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON mysql.* TO admin@'%' WITH GRANT OPTION;
CREATE USER 'admin'@'localhost' IDENTIFIED BY 'shurumima';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'localhost'  WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON mysql_innodb_cluster_metadata.* TO admin@'localhost' WITH GRANT OPTION;
GRANT RELOAD, SHUTDOWN, PROCESS, FILE, SUPER, REPLICATION SLAVE, REPLICATION CLIENT, CREATE USER ON *.* TO admin@'localhost' WITH GRANT OPTION;
GRANT SELECT ON performance_schema.* TO admin@'localhost' WITH GRANT OPTION;
GRANT SELECT ON sys.* TO admin@'localhost' WITH GRANT OPTION;
GRANT SELECT, INSERT, UPDATE, DELETE ON mysql.* TO admin@'localhost' WITH GRANT OPTION;
CREATE USER 'mon'@'%' IDENTIFIED BY 'shurumima';
GRANT SELECT ON mysql_innodb_cluster_metadata.* TO mon@'%';
GRANT SELECT ON performance_schema.global_status TO mon@'%';
GRANT SELECT ON performance_schema.replication_applier_configuration TO mon@'%';
GRANT SELECT ON performance_schema.replication_applier_status TO mon@'%';
GRANT SELECT ON performance_schema.replication_applier_status_by_coordinator TO mon@'%';
GRANT SELECT ON performance_schema.replication_applier_status_by_worker TO mon@'%';
GRANT SELECT ON performance_schema.replication_connection_configuration TO mon@'%';
GRANT SELECT ON performance_schema.replication_connection_status TO mon@'%';
GRANT SELECT ON performance_schema.replication_group_member_stats TO mon@'%';
GRANT SELECT ON performance_schema.replication_group_members TO mon@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
"
$mysql_base_dir/bin/mysql -P$mysql_port  -S $mysql_sock  -e "show databases"
