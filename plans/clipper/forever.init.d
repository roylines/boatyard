#!/bin/bash
# chkconfig: 2345 81 20
# description: node.js and forever start up script
# processname: forever

. /etc/init.d/functions
 
NAME=forever
SOURCE_DIR=/home/nodeuser/current
SOURCE_FILE=app.js
 
user=nodeuser
pidfile=/var/run/$NAME.pid
logfile=/var/log/$NAME.log
forever_dir=/user/local/bin
 
node=/usr/local/bin/node
forever=/usr/local/bin/forever
sed=/bin/sed
 
export PATH=$PATH:/usr/local/bin
export NODE_PATH=$NODE_PATH:/usr/local/lib/node_modules
 
start() {
  echo "Starting $NAME node instance: "
 
  if [ "$foreverid" == "" ]; then
    # Create the log and pid files, making sure that 
    # the target use has access to them
    touch $logfile
    chown $user $logfile
 
    touch $pidfile
    chown $user $pidfile
 
    # Launch the application
    daemon --user=root \
      $forever start -p $forever_dir --pidfile $pidfile -l $logfile \
      -a -d $SOURCE_DIR/$SOURCE_FILE
    RETVAL=$?
  else
    echo "Instance already running"
    RETVAL=0
  fi
}
 
stop() {
  echo -n "Shutting down $NAME node instance : "
  if [ "$foreverid" != "" ]; then
    $node $SOURCE_DIR/prepareForStop.js
    $forever stop -p $forever_dir $id
  else
    echo "Instance is not running";
  fi
  RETVAL=$?
}
 
if [ -f $pidfile ]; then
  read pid < $pidfile
else
  pid = ""
fi
 
if [ "$pid" != "" ]; then
  # Gnarly sed usage to obtain the foreverid.
  sed1="/$pid\]/p"
  sed2="s/.*\[\([0-9]\+\)\].*\s$pid\].*/\1/g"
  foreverid=`$forever list -p $forever_dir | $sed -n $sed1 | $sed $sed2`
else
  foreverid=""
fi
 
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status -p ${pidfile}
    ;;
  *)
    echo "Usage:  {start|stop|status}"
    exit 1
    ;;
esac
exit $RETVAL