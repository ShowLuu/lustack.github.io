#!/bin/bash
# 上面中的 #! 是一种约定标记, 它可以告诉系统这个脚本需要什么样的解释器来执行;

USERNAME=zhanglu
PROJECT_PATH=/Users/zhanglu/Desktop/lu/workspace/南京数脉动力信息技术有限公司/work_space/电信5楼项目组/5G消息/lu_work_space/RCS
MVN=/Users/zhanglu/Library/Application\ Support/JetBrains/Toolbox/apps/IDEA-U/ch-0/202.7660.26/IntelliJ\ IDEA.app/Contents/plugins/maven/lib/maven3/bin/mvn

stop(){
	pids=$(ps -au$USERNAME | grep $1 | grep -v grep | grep -v deploy | awk '{print $2}')	
	for pid in ${pids[@]}
	do
		echo killed pid $pid
		kill -9 $pid
	done
}

start(){
	jars=$(find $1 -name $2)
	echo jars
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
		read -p "请输入关闭rcs-jar进程匹配规则:" rule
    stop $rule
    sleep 5
    read -p "请输入启动rcs-jar文件夹路径:" dir
    read -p "请输入启动rcs-jar文件匹配规则:" jarPath
    start $dir $jarPath
}

status(){
	jars=$(find $1 -name $2)
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
	files=$(find $1 -name $2)
	echo asdasd
	read -p "远端ip:" ip
	read -p "远端port:" port
	read -p "远端user:" username
	read -p "远端password:" password
	read -p "远端文件｜目录:" targetPath
 	for file in ${files[@]}
	do
		#scp -p $port $jar $username@$ip:$targetPath
		./scp-expect.sh $ip $port $username $password $file $targetPath
	done 
}

remoteStart(){
	#jar路径也是脚本路径
	filePath=/lu/test
	read -p "jar名称" jarName
	ssh root@47.111.68.15
	cd filePath
	#sh ${filePath}/shell.sh start $filePath jarName
}

#ssh root@101.132.36.1 << eeooff
#ls
#cd /lu/test
#ls
#eeooff    

#根据输入参数，选择执行对应方法，不输入则执行使用说明
case "$1" in
"start")
    start $2 $3 #目录 匹配文件
    ;;
"stop")
    stop $2
    ;;
"status")
    status $2 $3 #目录 匹配文件
    ;;
"restart")
    restart
    ;;
"package")
		package
		;;
"upload")
		upload $2 $3
		;;
"remoteStart")
		remoteStart
		;;		
*)
esac

#ps -auzhanglu | grep '.*rcs.*.jar' | grep -v grep | grep -v deploy | awk '{print $2}'	#'com.jshb.*$'
#find /Users/zhanglu/Desktop/lu/workspace/南京数脉动力信息技术有限公司/work_space/电信5楼项目组/5G消息/lu_work_space/RCS -name 'rcs-*.jar'

#sh shell.sh stop .*rcs.*.jar
#sh shell.sh start /Users/zhanglu/Desktop/test rcs-*.jar
#sh shell.sh restart
#sh shell.sh status /Users/zhanglu/Desktop/test rcs-*.jar
#sh shell.sh package
#sh shell.sh upload /Users/zhanglu/Desktop/test rcs-*.jar 47.111.68.15
#sh shell.sh remoteStart
