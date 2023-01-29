参考：

- [ELK Stack权威指南](https://www.bookstack.cn/read/logstash-best-practice-cn/README.md)
- [Elasticseach官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/6.8/index.html)
- [Logstash官方文档](https://www.elastic.co/guide/en/logstash/6.8/index.html)

# 一、基础知识

## 1、部署运行

- nohup方式

  ```shell
  nohup command &
  ```

- Screen方式

  ###### 其父进程不是sshd登陆会话，而是screen。既能避免用户推出进程消失问题，还能随时重新接管回终端继续操作

  ```shell
  创建独立的screen
  screen -dmS elkscreen_demo
  
  接管连入创建的elkscreen_demo
  screen -r elkscreen_demo
  
  查看列表
  screen -list
  screen -ls
  
  关闭elkscreen_demo回话
  screen -X -S elkscreen_demo quit
  
  运行之后，想要断开环境，不要Ctrl+C，而是Ctrl+A+D
  ```

## 2、配置语法

- 区段(section)，用`{}`定义

- 数据类型

  - bool `debug=>true`
  - string `host=>hostname`
  - number `port=>124`
  - array `match=>["datetime", "linux"]`
  - hash `options=>{"k1": "v1"}`

- 字段引用，`[]`表示

- 条件判断

  - 比较运算符：`==`,`~=`,`<`,`>`,`<=`,`>=`
  - 正则表达式：`=~`,`!~`
  - inclusion：`in`,`not in`
  - boolean：`and`,`or`,`nand`,`xor`
  - unary：`!()`

  ```ruby
  if("_grokparsefailure" not in [tags]){
  		  
  }else if([status] !~ /^2\d\d/ and [url] == "/test"){
    
  }else{
    
  }
    
  //非空判断
  if([ip] and [ip] != ""){
    
  }
  ```

- 命令行参数

  - -e：执行

    - ./bin/logstash -e '一段脚本'

    - ./bin/logstash -e '' 这个参数有默认值

      ```ruby
      input {
          stdin { }
      }
      output {
          stdout { }
      }
      ```

  - -config|-f：文件

    - 指定文件脚本执行：./bin/logstash -f /script/test.conf

  - -configtest|-t：测试

    - 用来测试logs ta sh读取到的配置文件的语法是否能正常解析

  - -log|-l：日志

    - 默认输出日志到控制台，可以让其输出到文件，bin/logstash -l logs/logstash.log

  - -filterworkers|-w：工作线程

    - bin/logstash -w 5：让过滤插件运行5个线程，并行处理input

  - -verbose：输出一定的调试日志

  - -debug：输出更多的调试日志

# 二、输入插件(Input)

## 1、标准输入(Stdin)

- 配置

  ```ruby
  input {
      stdin {
          add_field => {"key" => "value"}
          codec => "plain"
          tags => ["add"]
          type => "std"
      }
  }
  ```
  - add_field：增加一个字段key
  - codec：编解码方式
  - tags：增加标签字段
  - type：增加类型字段

  type、tags是logstash事件中的两个特殊的字段

- 体验一把

  ```ruby
  input {
      stdin {
          type => "web"
      }
  }
  filter {
      if [type] == "web" {
          grok {
              match => ["message", %{COMBINEDAPACHELOG}]
          }
      }
  }
  output {
      if "_grokparsefailure" in [tags] {
          nagios_nsca {
              nagios_status => "1"
          }
      } else {
          elasticsearch {
          }
      }
  }
  ```

  

## 2、读取文件(File)

- 概述：logstash会增量的方式去监控数据｜读取数据源，为了保证可以增量读取，它会自己维护一个读取位置，保存在*.sincedb* 的数据库文件中，*sincedb 文件中记录了每个被监听的文件的 inode, major number, minor number 和 pos。*

- 配置

  ```ruby
  input
      file {
          path => ["/var/log/*.log", "/var/log/message"]
          type => "system"
          start_position => "beginning"
      }
  }
  ```

  - path：string、array，支持模糊匹配，`path => "/path/to/*/*/*/*.log`，不支持类似于这种的`path => "/path/to/%{+yyyy/MM/dd/hh}.log"`
  - codec：对数据进行解析，可以把json串转为json对象，默认plain文本
  - discover_interval：logstash 每隔多久去检查一次被监听的 `path` 下是否有新文件。默认值是 15 秒
  - exclude：不想被监听的文件可以排除出去，这里跟 `path` 一样支持 glob 展开
  - sincedb_path：指定*.sincedb* 的数据库文件输出文件地址，可以是`.log`,`.txt`,`sincedb`...
  - sincedb_write_interval：logstash 每隔多久写一次 sincedb 文件，默认是 15 秒
  - stat_interval：logstash 每隔多久检查一次被监听文件状态（是否有更新），默认是 1 秒。
  - start_position：logstash从什么位置开始读取文件数据，默认是结束位置(实际上是logstash记录的最后一个位置开始，有点类似于kafka分区拉取消费)，可以指定从头开始读取 `start_position => "beginning"`

## 3、读取网络数据(TCP)

- 开启一个端口服务，监听数据(TCP)

  ```ruby
  input{
  		tcp{
  				port => 8888
  				mode => "server"
  				ssl_enable => false
  		}
  }
  
  output{
  		stdout{}
  }
  ```

  - 运行logstash脚本
  - 客户端往端口发送数据：` nc 127.0.0.1 8888 < tcp.log`

## 4、生成测试数据(Generator)

- 确定linux上安装了pv：`yum install pv`

- 测试pipe和filter效率

  ```ruby
  input {
      generator {
          count => 10000000
          message => '{"key1":"value1","key2":[1,2],"key3":{"subkey1":"subvalue1"}}'
          codec => json
      }
  }
  ```

  ./bin/logstash -f generator_null.conf

- 测试长期运行时候的效率

  ```ruby
  input {
      generator {
          count => 10000000
          message => '{"key1":"value1","key2":[1,2],"key3":{"subkey1":"subvalue1"}}'
          codec => json
      }
  }
  
  output {
      stdout {
          codec => dots
      }
  }
  ```

  ./bin/logstash -f generator_dots.conf | pv -abt > /dev/null

## 5、读取Syslog数据

## 6、读取Redis数据

- 支持三种数据类型

  - list => blpop
  - Channel => subscribe
  - pattern_channdel => psubscribe

- list队列方式

  ```ruby
  input {
      redis {
          batch_count => 1
          data_type => "list"
          key => "elk_demo"
          host => "server"
          port => 6379
          db => 0
          threads => 5
      }
  }
  
  output{
  		stdout{codec => "json_lines"}
  }
  ```

  

## 7、读取Collected数据

###### 对服务器基本的**CPU、内存、网卡流量、磁盘 IO 以及磁盘空间占用**情况的监控的工具

# 三、编解码插件(Codec)

- Input -> decode -> filter -> encode -> output

- 编解码器插件可更改事件的数据表示形式。编解码器本质上是流过滤器，可以作为输入或输出的一部分进行操作。

- 常用的类型

  | 插入                                                         | 描述                                                   | Github仓库                                                   |
  | ------------------------------------------------------------ | ------------------------------------------------------ | ------------------------------------------------------------ |
  | [csv](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-csv.html) | 获取CSV数据，进行解析并传递。                          | [logstash编解码器csv](https://github.com/logstash-plugins/logstash-codec-csv) |
  | [dots](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-dots.html) | 每个事件发送1点`stdout`用于性能跟踪                    | [logstash编解码器点](https://github.com/logstash-plugins/logstash-codec-dots) |
  | [es_bulk](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-es_bulk.html) | 将Elasticsearch批量格式与元数据一起读取为单独的事件    | [logstash-codec-es_bulk](https://github.com/logstash-plugins/logstash-codec-es_bulk) |
  | [gzip_lines](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-gzip_lines.html) | 读取`gzip`编码的内容                                   | [logstash-codec-gzip_lines](https://github.com/logstash-plugins/logstash-codec-gzip_lines) |
  | [java_line](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-java_line.html) | 编码和解码面向行的文本数据                             | [核心插件](https://github.com/elastic/logstash/blob/7.9/logstash-core/src/main/java/org/logstash/plugins/codecs/Line.java) |
  | [java_plain](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-java_plain.html) | 处理事件之间没有定界符的文本数据                       | [核心插件](https://github.com/elastic/logstash/blob/7.9/logstash-core/src/main/java/org/logstash/plugins/codecs/Plain.java) |
  | [json](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-json.html) | 读取JSON格式的内容，为JSON数组中的每个元素创建一个事件 | [logstash-codec-json](https://github.com/logstash-plugins/logstash-codec-json) |
  | [json_lines](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-json_lines.html) | 读取以换行符分隔的JSON                                 | [logstash-codec-json_lines](https://github.com/logstash-plugins/logstash-codec-json_lines) |
  | [line](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-line.html) | 读取行文本数据                                         | [logstash编解码器线](https://github.com/logstash-plugins/logstash-codec-line) |
  | [multiline](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-multiline.html) | 将多行消息合并为一个事件                               | [Logstash编解码器多行](https://github.com/logstash-plugins/logstash-codec-multiline) |
  | [plain](https://www.elastic.co/guide/en/logstash/7.9/plugins-codecs-plain.html) | 读取纯文本，事件之间没有定界                           | [Logstash编解码器纯](https://github.com/logstash-plugins/logstash-codec-plain) |

- 实操：

  - 采用各个编码方式`codec => "json"`

  - 合并多行数据并为一个事件处理

    - 示例：

      ```ruby
      input {
          stdin {
              codec => multiline {
                  pattern => "^\["
                  negate => true
                  what => "previous"
              }
          }
      }
      
      输入：
      [Aug/08/08 14:54:03] hello world
      [Aug/08/09 14:54:04] hello logstash
          hello best practice
          hello raochenlin
      
      结果：
      {
          "@timestamp" => "2014-08-09T13:32:03.368Z",
             "message" => "[Aug/08/08 14:54:03] hello world\n",
            "@version" => "1",
                "host" => "raochenlindeMacBook-Air.local"
      }
      {
          "@timestamp" => "2014-08-09T13:32:24.359Z",
             "message" => "[Aug/08/09 14:54:04] hello logstash\n\n    hello best practice\n\n    hello raochenlin\n",
            "@version" => "1",
                "tags" => [
              [0] "multiline"
          ],
                "host" => "raochenlindeMacBook-Air.local"
      }
      ```

    

# 四、过滤插件(Filter)

## 1、Grok正则获取

- 参考：

  - [了解](https://www.jianshu.com/p/443f1ea7b640)
  - [表达式模版](https://github.com/elastic/logstash/blob/v1.4.2/patterns/grok-patterns)

- 例子：

  ```ruby
  输入：begin 123.456 end
  filter {
     if([type] == "grok"){
        grok {
            match => {
                "message" => "%{WORD} %{NUMBER:request_time:float} %{WORD}"
            }
        }
     }else if([type] == "groks"){
       	match => [
        		"message", "(?<request_time>\d+(?:\.\d+)?)",
            "message", "%{SYSLOGBASE} %{DATA:message}",
            "message", "(?m)%{WORD}"
      	]
     }
  }
  解析出 123.456 值，把值赋给request_time字段(string)，再把string转为float
  ```
  
  - 正则赋值：(?<`field`>表达式)
  
- 表达式测试：kibana

## 2、时间处理(Date)

- 事件格式转换

  ```ruby
  filter {
      grok {
          match => ["message", "%{HTTPDATE:logdate}"]
      }
      date {
          match => ["logdate", "dd/MMM/yyyy:HH:mm:ss Z"]
      }
  }
  ```

- 时区8小时问题
  
  - 在 Kibana 上，读取浏览器的当前时区，然后在页面上转换时间

## 3、数据修改(Mutate)

- 类型转换

  - 可以转换的类型：`int`,`float`,`string`

  - 格式：

    ```ruby
    filter {
        mutate {
            convert => ["request_time", "float"]
        }
    }
    ```

  - 上面是转换单个值，也可以对数组类型转换，例如：`["1","2"]` 转换成 `[1,2]`，但不能对哈希类型转换，可以采用ruby搞定

- 字符串处理

  - 格式：

    ```ruby
    filter{
    		mutate{
    				split => ["data", ","]
    		}
    }
    ```

    - split `["message", "|"]`

  - join `["message", ","]`

  - merge 把`newData`的数据合并到`message`，`["message", "newData"]` 

  - lowercase

  - uppercase

- 字段处理

  - rename：重命名某个字段，如果字段已经存在，会被覆盖 `["syslog_host", "host"]`
  - update：更新某个字段的内容，如果字段不存在，不会新建
  - replace：更新某个字段的内容，如果字段不存在，自动添加

## 4、GeoIp查询归类

- 参考

  - [参考官网](https://www.elastic.co/guide/en/logstash/7.9/plugins-filters-geoip.html)
  - [应用参考](http://www.51niux.com/?id=212)

- 根据ip地址，查询地址归类信息

- 示例

  ```ruby
  input {
      redis {
          batch_count => 1
          data_type => "list"
          key => "elk_demo"
          host => "ip"
          port => 6379
          db => 0
          threads => 5
      }
  }
  
  filter{
  		 geoip {
          source => "ip地址必传"
      }
  }
  
  output{
  		stdout{codec => "json_lines"}
  }
  
  响应：
  {
  	"name": "lu",
  	"message": "ip",
  	"age": 18,
  	"@version": "1",
  	"geoip": {
  		"region_name": "Zhejiang",
  		"continent_code": "AS",
  		"longitude": 120.1614,
  		"ip": "ip",
  		"country_name": "China",
  		"latitude": 30.2936,
  		"country_code3": "CN",
  		"region_code": "33",
  		"location": {
  			"lat": 30.2936,
  			"lon": 120.1614
  		},
  		"timezone": "Asia/Shanghai",
  		"country_code2": "CN",
  		"city_name": "Hangzhou"
  	},
  	"@timestamp": "2020-09-03T08:33:45.763Z"
  }
  ```

- 指定自己需要的字段

  ```ruby
  filter {
      geoip {
          fields => ["city_name", "continent_code", "country_code2", "country_code3", "country_name", "dma_code", "ip", "latitude", "longitude", "postal_code", "region_name", "timezone"]
      }
  }
  ```

## 5、JSON编解码

- 示例

  ```
  案例一：
  filter {
      json {
          source => "message"
          target => "jsoncontent"
      }
  }
  
  运行结果：
  {
      "@version": "1",
      "@timestamp": "2014-11-18T08:11:33.000Z",
      "host": "web121.mweibo.tc.sinanode.com",
      "message": "{\"uid\":3081609001,\"type\":\"signal\"}",
      "jsoncontent": {
          "uid": 3081609001,
          "type": "signal"
      }
  }
  
  案例二：
  filter {
      json {
          source => "message"
          target => "jsoncontent"
      }
  }
  
  运行结果
  {
      "@version": "1",
      "@timestamp": "2014-11-18T08:11:33.000Z",
      "host": "web121.mweibo.tc.sinanode.com",
      "message": "{\"uid\":3081609001,\"type\":\"signal\"}",
      "uid": 3081609001,
      "type": "signal"
  }
  ```
  - source：指定待解析的json串
  - target：封装解析好的json参数

## 6、split拆分事件

- 把一行数据拆分成多个事件处理

  - 示例：

    ```ruby
    filter {
        split {
            field => "message"
            terminator => "#"
        }
    }
    
    输入：test1#test2
    
    结果：
    {
        "@version": "1",
        "@timestamp": "2014-11-18T08:11:33.000Z",
        "host": "web121.mweibo.tc.sinanode.com",
        "message": "test1"
    }
    {
        "@version": "1",
        "@timestamp": "2014-11-18T08:11:33.000Z",
        "host": "web121.mweibo.tc.sinanode.com",
        "message": "test2"
    }
    ```

    

## 7、UserAgent匹配显示浏览器信息

- 示例：

  ```
  消息：
  {"user_agent": "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36"}
  
  执行脚本：
  input{
  		file{
  		  	path => ["/lu/tool/dev/new_es/logstash-6.8.8/script_demo1/file/access_log"]
  		    sincedb_path => "/lu/tool/dev/new_es/logstash-6.8.8/script_demo1/file/db/index.txt"
  		    codec => "json"
  		}
  }
  
  filter{
      if [user_agent] != "-" {
  			  useragent {
  			    	target => "ua"
  			    	source => "user_agent"
  			  }
  		}
  }
  
  output{
  		stdout{}
  }
  
  响应结果：
  {
      "@timestamp" => 2020-09-03T14:38:57.829Z,
              "ua" => {
            "minor" => "0",
            "build" => "",
           "device" => "Other",
            "patch" => "2883",
          "os_name" => "Windows",
               "os" => "Windows",
            "major" => "55",
             "name" => "Chrome"
      },
            "host" => "localhost.localdomain",
        "@version" => "1",
      "user_agent" => "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.87 Safari/537.36",
            "path" => "/lu/tool/dev/new_es/logstash-6.8.8/script_demo1/file/access_log"
  }
  
  ```

  

## 8、Key-Value切分

- 解析一行数据，将有规律的数据，拆分成kv。常用场景，get请求url

  - 示例

    ```ruby
    消息：https://www.baidu.com/search?user=lu&age=18&status=1
    
    执行脚本
    input{
    	stdin{
    	
    	}
    }
    
    filter{
    	kv{
    		prefix => "params_"
    		source => "message"
    		field_split => "&"
    		value_split => "="
    	}
    }
    
    output{
    	stdout{}
    }
    
    响应结果
    {
                                      "params_age" => "18",
                                   "params_status" => "1",
                                            "host" => "localhost.localdomain",
        "params_https://www.baidu.com/search?user" => "lu",
                                         "message" => "https://www.baidu.com/search?user=lu&age=18&status=1",
                                      "@timestamp" => 2020-09-03T14:44:50.129Z,
                                        "@version" => "1"
    }
    
    ```

## 9、万能的Ruby处理

## 10、数值统计(Metrics)

- 参考

  - [参考官方文档](https://www.elastic.co/guide/en/logstash/6.8/plugins-filters-metrics.html)

- Meter速率阈值检测

  - 示例：最近1分钟 [参考](https://www.cnblogs.com/stackflow/p/6071807.html)

    ```ruby
    输入消息
    
    执行脚本
    input{
    	stdin{
    		codec => "json"
    	}
    }
    
    filter {
        metrics {
          	//计数器保存的字段
            meter => "error.%{status}.rate_1m"
            add_tag => "metric"
          	//计算实时5s内的数据才统计
            ignore_older_than => 5
          	//创建度量标准事件时的刷新间隔
          	flush_interval => 5
        }
        if "metric" in [tags] {
            ruby {
              	//如果status==504小于10，就忽略该事件
                code => "event.cancel if event['error.504.rate_1m'] * 60 < 10"
            }
        }
    }
    
    output {
      	stdout{}
        if "metric" in [tags] {
            exec{
                command => "echo \"Out of threshold: %{error.504.rate_1m}\""
            }
        }
    }
    
    响应结果
    ```

- Timer异常检测

# 五、输出插件(Output)

## 1、标准输出(Stdout)

- 示例

  ```ruby
  output {
      stdout {
          codec => rubydebug
          workers => 2
      }
  }
  ```

  workers：多线程模式

## 2、保存成文件(File)

- 示例

  ```ruby
  output {
      file {
          path => "/path/to/%{+yyyy/MM/dd/HH}/%{host}.log.gz"
          message_format => "%{message}"
          gzip => true
      }
  }
  ```

  - message_format：默认输出JSON形式的数据，这里只是想把数据源的数据原封不动的保存下来，故引用了message数据

## 3、保存进elasticsearch

- 参考

  - [官方文档](https://www.elastic.co/guide/en/logstash/6.8/plugins-outputs-elasticsearch.html)

- 示例

  ```ruby
  输出格式：
  output{
      stdout{}
      elasticsearch{
          hosts => "127.0.0.1:9200"
          index => "logstash-elk_file-%{+YYYY.MM.dd}"
          template_name => "logstash-elk_file"
      	  template_overwrite => true
          template => "/es_maapping01.json"
      }
  }
  
  模版格式：
  {
  	"template": "logstash-elk_file",
  	"settings": {},
  	"mappings": {
  		"doc": {
  			"properties": {
  
  			}
  		}
  	}
  }
  ```

  - 按照规则生成索引文件，索引最好以logstash开头，不然kibana数据分析的时候会有问题，例如对于geo_point
  - 按照模板生成索引mapping

## 4、输出到Redis

- [参考官方文档](https://www.elastic.co/guide/en/logstash/7.9/plugins-outputs-redis.html)

- 支持的数据类型

  - list => rush
  - channel 发布订阅

- list队列

  - 示例

    ```ruby
    input { stdin {} }
    output {
        redis {
            data_type => "list"
            key => "elk_output_list"
            host => "101.132.36.1"
            password => "Showlu18"
            port => 6379
            db => 0
        }
    }
    ```

- channel 发布订阅

  - 示例

    ```shell
    redis客户端发布通道
    SUBSCRIBE elk_output_channel-2020.09.04
    
    执行脚本
    input { stdin {} }
    output {
        redis {
            data_type => "channel"
            key => "elk_output_channel-%{+YYYY.MM.dd}"
            host => "101.132.36.1"
            port => 6379
            password => "Showlu18"
            db => 0
        }
    }
    ```

## 5、输出网络数据(TCP)

- 示例

  ```ruby
  linux开启tcp服务端口
  nc -l 8888
  输入消息：asdasd阿萨说
  
  执行脚本：
  input{
  		stdin{}
  }
  output {
      tcp {
          host  => "127.0.0.1"
          port  => 8888
          codec => "json"
      }
  }
  
  响应结果：
  {"host":"localhost.localdomain","@version":"1","@timestamp":"2020-09-04T07:43:52.753Z","message":"asdasd阿萨说"}
  ```

## 6、输出到Statsd

## 7、报警到Nagios

## 8、发送邮件(Email)

- [参考官方文档](https://www.elastic.co/guide/en/logstash/6.8/plugins-filters-metrics.html)

- 示例：

  ```ruby
  input{
  	stdin{}
  }
  
  filter{}
  
  output{
  	email{
  		address => "smtpdm.aliyun.com"
  		username => "showlu@mail.showlu.top"
  		password => "ShowLu19970108x"
  		port => 80
  		from => "showlu@mail.showlu.top"
  		to => "1309617271@qq.com"
  		subject => "Elk邮件"
  		body => "%{message}"
  	}
  }
  ```

  

## 9、调用命令执行(Exec)

- 示例

  ```ruby
  output {
      exec {
          command => "sendsms.pl \"%{message}\" -t %{user}"
      }
  }
  ```

## 10、输出到Kafka

- [参考官方文档](https://www.elastic.co/guide/en/logstash/6.8/plugins-filters-metrics.html)

- 示例

  ```ruby
  input{
  	stdin{}
  }
  
  filter{}
  
  output{
  	kafka{
  		bootstrap_servers => "192.168.0.107:9092"
  		topic_id => "elk_test"
  	}
  }
  ```



# 六、实操

## 1、file

- input文件路径，模糊匹配
- sincedb记录文件读取位置
- 过滤器编写，grok
- 输出es，注意索引模版，index最好使用logstash开头，如果要用geoIp查询归类，需要设置location类型为geo_point类型，如果需要在kibana展示，index必须是以logstash开头

## 2、tcp

- 客户端脚本编写，客户端传输的数据编码问题
- logstash作为服务端，过滤器等

## 3、udp

- 同tcp注意

## 4、http

- 没啥好说的

## 5、jdbc

- 参考
  
- [脚本解释以及时区问题](https://blog.csdn.net/lvyuan1234/article/details/78190766)
  
- 注意数据库版本问题，可能需要升级jar

- 增量查询，若是timestamp类型，需要注意时区问题[Mysql日期加减](https://blog.csdn.net/qq_39588003/article/details/90758827)

- 注意sincedb记录文件读取位置

- 设置周期查询的方式,schedule 分 时 天 月 年

  ```shell
  * * * * * 								每分钟一次
  * 5 * 1-3 * 							从一月到三月的每天凌晨5点每分钟执行一次。
  0 * * * * 								将在每天每小时的第0分钟执行。
  0 6 * * * America/Chicago 每天早上6:00（UTC / GMT -5）执行。
  ```

  

## 6、redis

- 两种模式，channel通道和list队列，注意客户端->redis->logstash 过程中数据的编码格式转换

## 7、kafka

- 作为输入没有offset的概念，logstash只接收kafka的实时流

## 8、es

- 待考虑
