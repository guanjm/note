#!/bin/bash

init() {
  datadir='./data'
  tmpdir='./tmp'
  logdir='./log'
  logfile=$logdir'/mysql-error.log'
  if [ ! -e $tmpdir ]; then
    mkdir $tmpdir
  fi
  if [ ! -e $logdir ]; then
    mkdir $logdir
  fi
  if [ ! -e $logfile ]; then
    touch $logfile
  fi
  '/home/mysql/mysql-8.0.20-linux-x86_64-minimal/bin/mysqld' --defaults-file=/home/mysql/mysql_3301/my.cnf \
                                                             --initialize-insecure
  if [ $? -eq 0 ]; then
    echo 'init success!'
  else
    echo -e "init fail:"
    [ -e $logfile ] && cat $logfile
    rm -rf $datadir
    rm -rf $tmpdir
    rm -rf $logdir
  fi
}

start() {
  nohup '/home/mysql/mysql-8.0.20-linux-x86_64-minimal/bin/mysqld' --defaults-file=/home/mysql/mysql_3301/my.cnf &
}

funType=$1
while [[ ($funType != 'init' && $funType != 'start' && $funType != 'stop') ]]; do
	read -p 'please input funType [ init | start | stop ]: ' input
	funType=$input
done
$funType
