#!/bin/sh
## java env

API_NAME=bapfopm-cbfsms-fpass-service-1.0-SNAPSHOT
JAR_NAME=$API_NAME\.jar
JAR_DIR=/home/bapfopm/application/fpass/service
#PID  代表是PID文件
PID=$API_NAME\.pid

#使用说明，用来提示输入参数
usage() {
    echo "Usage: sh 执行脚本.sh [bak|start|stop|restart|status]"
    exit 1
}


#1 备份
bak(){
  if [ -f $JAR_DIR/$JAR_NAME ]; then
   echo ">>> 备份是个好习惯 <<<"
   mv  $JAR_DIR/$JAR_NAME $JAR_DIR/bak/$JAR_NAME.`date +%y%m%d`.bak

  else
   echo ">>> jar 包不存在 <<<"
  fi
}

#检查程序是否在运行
is_exist(){
  pid=`ps -ef|grep $JAR_NAME|grep -v grep|awk '{print $2}' `
  #如果不存在返回1，存在返回0     
  if [ -z "${pid}" ]; then
   return 1
  else
    return 0
  fi
}

#启动方法
start(){
  is_exist
  if [ $? -eq "0" ]; then 
    echo ">>> ${JAR_NAME} is already running PID=${pid} <<<" 
  else 
    nohup java -server -Xmx16G -Xms16G    -Xss512K -XX:+UseG1GC -XX:MaxGCPauseMillis=100 -XX:+ParallelRefProcEnabled -XX:ErrorFile=/home/bapfopm/application/fpass/gclog/hs_err_pid%p.log -XX:HeapDumpPath=/home/bapfopm/application/fpass/gclog -XX:+HeapDumpOnOutOfMemoryError -XX:+PrintCommandLineFlags  -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintGC -Xloggc:./gc.log -jar $JAR_NAME >nohup.out 2>&1 &
    echo $! > $PID
    echo ">>> start $JAR_NAME successed PID=$! <<<"  
    tail -f nohup.out
   fi
  }

#停止方法
stop(){
  #is_exist
  pidf=$(cat $PID)
  #echo "$pidf"  
  echo ">>> api PID = $pidf begin kill $pidf <<<"
  kill $pidf
  rm -rf $PID
  sleep 2
  is_exist
  if [ $? -eq "0" ]; then 
    echo ">>> api 2 PID = $pid begin kill -9 $pid  <<<"
    kill -9  $pid
    sleep 2
    echo ">>> $JAR_NAME process stopped <<<"  
  else
    echo ">>> ${JAR_NAME} is not running <<<"
  fi  
}

#输出运行状态
status(){
  is_exist
  if [ $? -eq "0" ]; then
    echo ">>> ${JAR_NAME} is running PID is ${pid} <<<"
  else
    echo ">>> ${JAR_NAME} is not running <<<"
  fi
}

#重启
restart(){
  stop
  start
}

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
  "start")
    start
    ;;
  "stop")
    stop
    ;;
  "bak")
    bak
    ;;
  "status")
    status
    ;;
  "restart")
    restart
    ;;
  *)
    usage
    ;;
esac
exit 0
