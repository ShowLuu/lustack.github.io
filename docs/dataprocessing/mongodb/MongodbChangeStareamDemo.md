- [先搭建集群，该操作需要集群环境，主通知从]: https://blog.csdn.net/zhangcongyi420/article/details/92738646

- [shell体验]: https://cloud.tencent.com/developer/article/1711794

- [代码案例]: https://blog.csdn.net/qq_35561207/article/details/85201501

- [集群用户角色权限]: https://www.cnblogs.com/woxingwoxue/p/9888897.html

  

- 官网下载文件

- 解压，配置etc，mongoldb.conf文件

  ```shell
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
  ```

- 测试环境

  ```shell
  启动：./bin/mongod -f ./etc/mongod.conf 
  客户端连接：./bin/mongo
  退出关闭进程：ps -ef|grep mongod 
  一切就绪即可进行下一步
  ```

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
  ```

- 启动

  ```shell
  ./bin/mongod -f ./etc/mongod.conf 
  ./bin/mongod -f ./etc/s1.conf 
  ./bin/mongod -f ./etc/s2.conf 
  
  客户端连接集群：
  ./bin/mongo
  ```

- 分片集群认证设置

  - 在其中一台机器上生成keyfile

    - ```
      cd /mongodb文件夹啊
      在当前目录下生成文件：openssl rand -base64 753  > keyfile
      sudo chmod 400 keyfile
      ```

  - 创建管理员账号

    - ```
      use admin
      db.createUser({user: "root",pwd: "Showlu18",roles: [ { role: "root", db: "admin" } ]})
      db.auth("root", "Showlu18")
      
      use config
      db.createUser({user: "root",pwd: "Showlu18",roles: [ { role: "root", db: "admin" } ]})
      db.auth("root", "Showlu18")
      ```

  - 成功之后，关闭服务，修改配置文件

    ```
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
      replSetName: "lu" #需要监控的数据库
    security:
      authorization: enabled	#开启监控
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

  - 重启集群

    ```
    ./bin/mongod -f ./etc/mongod.conf 
    ./bin/mongod -f ./etc/s1.conf 
    ./bin/mongod -f ./etc/s2.conf 
    ```

  - 连接集群

    ```
    客户端连接：mongo --host 127.0.0.1 --port 27017 -u "root" -p'Showlu18' --authenticationDatabase "admin"
    客户端连接：
    	mongo --host 127.0.0.1  
    	use admin  
    	db.auth("root", "111111")
    ```

  - 连接完毕，可以试试命令，是否需要认证，不需要说明成功连接

    ```
    例如以下命令：
    show users
    show dbs
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