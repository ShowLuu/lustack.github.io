#!/bin/bash
# 上面中的 #! 是一种约定标记, 它可以告诉系统这个脚本需要什么样的解释器来执行;

USERNAME=zhanglu
PROJECT_PATH=/Users/zhanglu/Desktop/lu/workspace/南京数脉动力信息技术有限公司/work_space/电信5楼项目组/5G消息/lu_work_space/RCS
MVN=/Users/zhanglu/Library/Application\ Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/202.7660.26/IntelliJ\ IDEA.app/Contents/plugins/maven/lib/maven3/bin/mvn
LOCAL_JAR_DIR=/Users/zhanglu/Desktop/test 
REMOTE_JAR_DIR=/lu/test
RETOTE_IP=47.111.68.15
REMOTE_PORT=22
REMOTE_USER=root
REMOTE_PASSWORD=Showlu18

stop(){
  read -p "匹配规则[.*rcs.*.jar]:" rule
  if [[ $rule == '' ]]
  then
  	rule='.*rcs.*.jar'
  fi
	pids=$(ps -au$USERNAME | grep "$rule" | grep -v grep | grep -v deploy | awk '{print $2}')	
	for pid in ${pids[@]}
	do
		echo killed pid $pid
		kill -9 $pid
	done
}

start(){
	read -p "匹配规则[rcs-*.jar]:" rule
	if [[ $rule == '' ]]
  then
  	rule='rcs-*.jar'
  fi
	jars=$(find $1 -name "$rule")
	cd $1	
	for jar in ${jars[@]}
	do
		if [[ $jar == *rcs-server* ]]
		then
			nohup java -jar $jar &
			echo start jar $jar
			sleep 8
		elif [[ $jar == *rcs-config* ]]
		then
			nohup java -jar $jar &
			echo start jar $jar
			sleep 20
		fi
	done
	for jar in ${jars[@]}
	do
		if [[ $jar != *rcs-server* && $jar != *rcs-config* ]]
		then
			nohup java -jar $jar &
			echo start jar $jar
		fi
		sleep 6
	done
}

restart(){
		read -p "关闭jar匹配规则[.*rcs.*.jar]:" stopRule
		if [[ $rule == '' ]]
	  then
	  	stopRule='.*rcs.*.jar'
	  fi
    stop $stopRule
    sleep 5
    read -p "启动jar匹配规则[rcs-*.jar]:" startRule
    if [[ $rule == '' ]]
	  then
	  	startRule='rcs-*.jar'
	  fi
    start $1 $startRule
}
	
status(){
	read -p "匹配规则[rcs-*.jar]:" rule
	if [[ $rule == '' ]]
	then
	  	rule='rcs-*.jar'
	fi
	jars=$(find $1 -name "$rule")
	for jar in ${jars[@]}
	do
		pid=$(ps -au$USERNAME | grep $jar | grep -v grep | grep -v deploy | awk '{print $2}')	
		if [[ $pid == '' ]]
		then
			 echo '未启动:' $jar
		else
			 echo '已启动-['$pid']:' $jar
		fi
	done
}

#maven打包
package(){
	cd $PROJECT_PATH
	/Users/zhanglu/Library/Application\ Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/202.7660.26/IntelliJ\ IDEA.app/Contents/plugins/maven/lib/maven3/bin/mvn clean package -Dmaven.test.skip=true
}


#上传至服务器路径
upload(){
	read -p "匹配规则[rcs-*.jar]:" rule
	if [[ $rule == '' ]]
	then
	  	rule='rcs-*.jar'
	fi
	files=$(find $1 -name "$rule")
 	for file in ${files[@]}
	do
		#scp -p $port $jar $username@$ip:$targetPath
		#./scp-expect.sh $RETOTE_IP $REMOTE_PORT $REMOTE_USER $REMOTE_PASSWORD $file $REMOTE_JAR_DIR
/usr/bin/expect << EOF
    spawn scp -P $REMOTE_PORT $file $REMOTE_USER@$RETOTE_IP:$REMOTE_JAR_DIR
    expect {
            "(yes/no)?"
                    {
                            send "yes\n"
                            expect "*password:" {send "$REMOTE_PASSWORD\n"}
                    }
            "*password:"
                    {
                            send "$REMOTE_PASSWORD\n"
                    }
    }
    expect "100%"
    expect eof
EOF

	done 
}

remote(){
	#read -p '输入要执行的命令:' command
	#./ssh-expect.sh $RETOTE_IP $REMOTE_PORT $REMOTE_USER $REMOTE_PASSWORD $REMOTE_JAR_DIR $command
/usr/bin/expect << EOF
    set timeout -1
    spawn ssh -p $REMOTE_PORT $REMOTE_USER@$RETOTE_IP
    expect {
            "(yes/no)?"
                    {
                            send "yes\n"
                            expect "*password:" {send "$REMOTE_PASSWORD\n"}
                    }
            "*password:"
                    {
                            send "$REMOTE_PASSWORD\n"
                    }
    }
    expect "#*"
    send "cd $REMOTE_JAR_DIR\n"
    send "ls *.jar\n"
    expect eof
EOF

}

#ssh root@101.132.36.1 << eeooff
#ls
#cd /lu/test
#ls
#eeooff    

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"start")
    start $LOCAL_JAR_DIR #本地目录 - 远端目录
    ;;
"stop")
    stop $LOCAL_JAR_DIR	#本地目录 - 远端目录
    ;;
"status")
    status $LOCAL_JAR_DIR #本地目录 - 远端目录
    ;;
"restart")
    restart $LOCAL_JAR_DIR	#本地目录 - 远端目录
    ;;	
"package")
		package
		;;
"upload")
		upload $LOCAL_JAR_DIR	#本地目录
		;;
"remote")
		remote
		;;		
*)
esac

#ps -auzhanglu | grep '*rcs*.jar' | grep -v grep | grep -v deploy | awk '{print $2}'	#'com.jshb.*$'
#find /Users/zhanglu/Desktop/lu/workspace/南京数脉动力信息技术有限公司/work_space/电信5楼项目组/5G消息/lu_work_space/RCS -name 'rcs-*.jar'

#sh shell.sh stop
#sh shell.sh start 
#sh shell.sh restart
#sh shell.sh status 
#sh shell.sh package
#sh shell.sh upload
#sh shell.sh remote
