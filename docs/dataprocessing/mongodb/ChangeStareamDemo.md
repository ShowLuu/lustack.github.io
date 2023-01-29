# 一、ChangeStaream

- 先搭建集群，该操作需要集群环境，主通知从等... https://blog.csdn.net/zhangcongyi420/article/details/92738646
- shell体验：https://cloud.tencent.com/developer/article/1711794
- 代码案例：https://blog.csdn.net/qq_35561207/article/details/85201501

## 1、安装

- 官网下载文件

- 解压，配置etc，mongoldb.conf文件

  ```shell
  dbpath=/Users/zhanglu/Desktop/lu/tool/dev/mongodb/4.0.10/data/db/
  logpath=/Users/zhanglu/Desktop/lu/tool/dev/mongodb/4.0.10/log/mongod.log
  logappend = true
  bind_ip=127.0.0.1
  port = 27017
  fork = true
  ```

- 基本命令

  ```shell
  启动：./bin/mongod -f ./etc/mongod.conf 
  客户端连接：./bin/mongo 127.0.0.1:27017/lu
  退出：ps -ef|grep mongod 
  ```

## 2、基本操作

###### 自行百度，菜鸟教程够用了

https://www.runoob.com/mongodb/mongodb-remove.html

```shell
查：db.col.find().pretty()
增：db.col.insert({"name":"测试01"})
改：db.col.update({"name":"测试01"},{$set:{"name": "测试02"}})
删：db.col.remove({"name" : "测试02"})
```



## 3、配置集群启动

- 配置文件

  ```shell
  主：
  storage:
    journal:
      enabled: true
    dbPath: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/data/db/"
  systemLog:
    destination: file
    path: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/log/mongod.log"
    logAppend: true
  net:
    bindIp: "0.0.0.0"
    port: 27017
  replication:
    replSetName: "lu"
  security:
    authorization: enabled
    keyFile: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/keyfile"
  
  从1：
  storage:
    journal:
      enabled: true
    dbPath: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/data/db_s1/"
  systemLog:
    destination: file
    path: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/log/s1.log"
    logAppend: true
  net:
    bindIp: "0.0.0.0"
    port: 27018
  replication:
    replSetName: "lu"
  security:
    authorization: enabled
    keyFile: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/keyfile"
  
  从2：
  storage:
    journal:
      enabled: true
    dbPath: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/data/db_s2/"
  systemLog:
    destination: file
    path: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/log/s2.log"
    logAppend: true
  net:
    bindIp: "0.0.0.0"
    port: 27019
  replication:
    replSetName: "lu"
  security:
    authorization: enabled
    keyFile: "/Users/zhanglu/Desktop/lu/tool/dev/mongodb/mongodb-macos-x86_64-4.4.3/keyfile"
  ```

- 启动

  ```shell
  ./bin/mongod -f ./etc/mongod.conf 
  ./bin/mongod -f ./etc/s1.conf 
  ./bin/mongod -f ./etc/s2.conf 
  
  客户端连接集群：
  ./bin/mongo 127.0.0.1:27017/lu
  ```

- 配置集群

  ```shell
  步骤一：
  use lu
  
  
  步骤二：
  cfg={_id:"lu",members:[{_id:0,host:'127.0.0.1:27017',priority:2},{_id:1,host:'127.0.0.1:27018',priority:1},{_id:2,host:'127.0.0.1:27019',arbiterOnly:true}]}
  
  步骤三：
  rs.initiate(cfg)
  ```

- 测试

  ```shell
  一个客户端开启监视器：db.watch([],{maxAwaitTimeMS:60000})
  一个客户端对选择的database进行操作，观察日志输出
  db.col.insert({"name":"测试01"})
  db.col.update({"name":"测试01"},{$set:{"name": "测试02"}})
  db.col.remove({"name" : "测试02"})
  ```



## 4、用户密码验证

### 1.单机情况有用

https://docs.mongodb.com/manual/tutorial/enable-authentication/

```shell
创建管理员
db.createUser(
  {
    user: "root",
    pwd: "111111",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
  }
)

db.createUser(
  {
    user: "root",
    pwd: passwordPrompt(),
    roles: [ { role: "userAdminAnyDatabase", db: "admin" }, "readWriteAnyDatabase" ]
  }
)

查看创建的管理员账号
db.getUser("root")

重启mongodb集群

客户端连接：mongo --host 127.0.0.1 --port 27017 -u "root" -p'Showlu18' --authenticationDatabase "admin"
客户端连接：
	mongo --host 127.0.0.1  
	use admin  
	db.auth("root", "111111")
```

```shell
创建普通用户(权限：读写数据库lu， 只读数据库admin)
use lu
db.createUser(
  {
    user: "lu",
    pwd: "111111",
    roles: [ { role: "readWrite", db: "lu" },
             { role: "read", db: "test" } ]
  }
)
```



### 2.集群模式有用

https://www.cnblogs.com/woxingwoxue/p/9888897.html

```
use admin
db.createUser({user: "root",pwd: "Showlu18",roles: [ { role: "root", db: "admin" } ]})
db.auth("root", "Showlu18")

use config
db.createUser({user: "root",pwd: "Showlu18",roles: [ { role: "root", db: "admin" } ]})
db.auth("root", "Showlu18")
```

