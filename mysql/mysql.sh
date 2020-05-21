#!/bin/bash
mysql_path=/home/mysql/mysql-8.0.20-linux-x86_64-minimal
basename=$(basename $PWD)
port=${basename#mysql_}
basedir=$PWD
datadir=$basedir'/data'
general_log_file=$basedir'/log/mysql.log'
log_error=$basedir'/log/mysql-error.log'
pid_file=$basedir'/tmp/mysql.pid'
slow_query_log_file=$basedir'/log/mysql-slow.log'
socket=$basedir'/tmp/mysql.sock'
tmpdir=$basedir'/tmp'
lc_messages_dir=$mysql_path'/share'

init() {
  tmpdir=$basedir'/tmp'
  logdir=$basedit'/log'
  if [ ! -e $tmpdir ]; then
    mkdir $tmpdir
  fi
  if [ ! -e $logdir ]; then
    mkdir $logdir
  fi
  if [ ! -e $log_error ]; then
    touch $log_error
  fi
  $mysql_path'/bin/mysqld' --initialize-insecure \
                           --port=$port \
                           --basedir=$basedir \
                           --datadir=$datadir \
                           --general-log-file=$general_log_file \
                           --pid-file=$pid_file \
                           --slow_query_log_file=$slow_query_log_file \
                           --log-error=$log_error \
                           --socket=$socket \
                           --tmpdir=$tmpdir \
                           --lc-messages-dir=$lc_messages_dir
}

start() {
  $mysql_path'/bin/mysqld' --port=$port \
                           --basedir=$basedir \
                           --datadir=$datadir \
                           --general-log-file=$general_log_file \
                           --pid-file=$pid_file \
                           --slow_query_log_file=$slow_query_log_file \
                           --log-error=$log_error \
                           --socket=$socket \
                           --tmpdir=$tmpdir \
                           --lc-messages-dir=$lc_messages_dir
}

stop() {
  echo 'stop'
}

funType=$1
while [[ -z $funType || ($funType != 'init' && $funType != 'start' && $funType != 'stop') ]]; do
	read -p 'please input funType [ init | start | stop ]: ' input
	funType=$input
done
$funType
