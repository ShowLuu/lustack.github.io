# 一、基础学习

## 1、集群健康检查、文档CRUD

### 1、环境操作

#### 1、集群

- 集群健康检查：GET /_cat/health?v

#### 2、索引

- 快速查看集群中有哪些索引：GET /_cat/indices?v

- 开关

  ```
  POST lu_test/_open
  POST lu_test/_close
  索引关闭后，不可crud
  对于修改某些配置，需要先关闭索引
  ```

  

### 2、文档CRUD

#### 1、新增

```javascript
PUT /mall/product/1
{
    "name" : "gaolujie yagao",
    "desc" :  "gaoxiao meibai",
    "price" :  30,
    "producer" :      "gaolujie producer",
    "tags": [ "meibai", "fangzhu" ]
}
PUT /mall/product/2
{
    "name" : "jiajieshi yagao",
    "desc" :  "youxiao fangzhu",
    "price" :  25,
    "producer" :      "jiajieshi producer",
    "tags": [ "fangzhu" ]
}
PUT /mall/product/3
{
    "name" : "zhonghua yagao",
    "desc" :  "caoben zhiwu",
    "price" :  40,
    "producer" :      "zhonghua producer",
    "tags": [ "qingxin" ]
}
PUT /mall/product/4
{
 		 "name": "special yagao",
     "desc": "special meibai",
     "price": 50,
     "producer": "special yagao producer",
     "tags": ["meibai"]
}
```



#### 2、修改

```javascript
//全量替换
PUT /mall/product/1
{
	...
}
//部分修改
POST /mall/product/1/_update
{
  "doc": {
    "name": "lu"
  }
}
//显然部分更好，减少了一次查询出来全部数据的操作，降低了es并发情况
  
//脚本方式修改
POST lu_test/test/1/_update
{
  "script": {
    "inline": "ctx._source.count += params.count",
    "params": {
      "count": 1
    }
  }
}

//增加字段k,v
POST lu_test/test/1/_update
{
  "script": "ctx._source.age=1"
}
```



#### 3、删除

```javascript
DELETE /mall/product/1
```



#### 4、查询

```javascript
GET /mall/product/1

GET /test_index/test_type/_search?q=name:lu04
GET /test_index/test_type/_search?q=+name:lu04
GET /test_index/test_type/_search?q=-name:lu04
GET /test_index/test_type/_search?q=lu04 //_all
```



### 3、多种搜索方式

#### 1、query string search

#### 2、query DSL 

#### 3、query filter

```javascript
//filter搜索
GET /mall/product/_search
{
  "query": {
    "bool": {
      "must":{
        "match": {
          "name": "yagao"
        }
      },
      "filter": {
        "range": {
          "price": {
            "gt": 30
          }
        }
      }
    }
  }
}
```



#### 4、full-text search（全文检索）

```javascript
//全文检索、排序、分页
GET /mall/product/_search
{
  "query":{
    "match": {
      "name": "yagao"
    }
  },
  "sort": {
    "price": "desc"
  },
  "from": 0,
  "size": 2
}
```



#### 5、phrase search（短语搜索）

```javascript
//短语搜索
GET /mall/product/_search
{
  "query": {
    "match_phrase": {
    }
  }
}
```



#### 6、highlight search（高亮搜索结果）

```javascript
//高亮搜索结果
GET /mall/product/_search
{
  "query": {
    "match": {
      "producer": "producer"
    }
  },
  "highlight": {
    "fields":{
      "producer": {}
    }
  }
}
```



#### 7、批量查询,只能根据index、type、id

##### 	1、不同index、type、id

```javascript
GET /_mget
{
  "docs": [
    {
      "_index": "test_index",
      "_type": "test_type",
      "_id": 1
    },
    {
      "_index": "mall",
      "_type": "product",
      "_source": ["name"],
      "_id": 1
    }
  ]
}
```

##### 	2、同一个index、type,不同id

```javascript
GET /test_index/test_type/_mget
{
  "ids": [1,2]
}
```



#### 8、批量增删改 bulk

有哪些类型的操作可以执行呢？
（1）delete：删除一个文档，只要1个json串就可以了
（2）create：PUT /index/type/id/_create，强制创建
（3）index：普通的put操作，可以是创建文档，也可以是全量替换文档
（4）update：执行的partial update操作

##### 1、处理不同索引、不同文档类型、不同id

```javascript
POST /_bulk
{"create": {"_index": "test_index", "_type": "test_type", "_id": 3}}
{"name": "lu03"}
{"delete": {"_index": "test_index", "_type":"test_type", "_id": "1"}}
{"index": {"_index": "test_index", "_type": "test_type", "_id": 4}}
{"name": "lu04"}
{"update": {"_index": "test_index", "_type": "test_type", "_id": 2}}
{"doc":{"name": "doc01"}}
{"index": {"_index": "mall", "_type": "product", "_id": 5}}
{"name": "mall05"}
```

##### 2、处理相同索引不同文档类型或者相同索引相同文档类型，便捷写法

```javascript
POST /test_index/_bulk
{"create": {"_type": "test_type", "_id": 3}}
{"name": "lu03"}
{"delete": {"_type":"test_type", "_id": "1"}}
{"index": {"_type": "test_type", "_id": 4}}
{"name": "lu04"}
{"update": {"_type": "test_type", "_id": 2}}
{"doc":{"name": "doc01"}}

POST /test_index/test_type/_bulk
{"create": {"_id": 3}}
{"name": "lu03"}
{"delete": {"_id": "1"}}
{"index": {"_id": 4}}
{"name": "lu04"}
{"update": {"_id": 2}}
{"doc":{"name": "doc01"}}
```

##### 3、bulk size 最佳大小

​	bulk request会加载到内存里，不宜过大，需切合实际经验，找到最合适的点。

方法：1000～5000数据开始调优，聪数据大小角度看，5～15MB之间



### 4、聚合分析

#### 1、分组

```
//聚合分析
PUT /mall/_mapping/product
{
  "properties": {
    "tags": {
      "type": "text",
      "fielddata": false	//设置属性，将fielddata加载到内存中
    }
  }
}
//分组若不是数值，需要加关键字字段'.keyword'
GET /mall/product/_search
{
  "aggs": {
    "group_by_tags": {
      "terms": {
        "field": "tags.keyword"
      }
    }
  }
}
//搜索聚合
GET /mall/product/_search
{
  "query": {
    "match": {
      "name": "yagao"
    }
  },
  "size": 0,
  "aggs": {
    "group_by_tags": {
      "terms": {
        "field": "tags.keyword"
      }
    }
  }
}
```



#### 2、先分组，再算每组的平均值

```javascript
GET /mall/product/_search
{
  "size": 0,
  "aggs":{
    "group_by_tags": {
      "terms": {
        "field": "tags.keyword"
      },
      "aggs": {
        "avg_price": {
          "avg": {
            "field": "price"
          }
        }
      }
    }
  }
}
```



#### 3、先分组、再计算每组的平均值，按照平均值排序

```javascript
GET /mall/product/_search
{
  "size": 0,
  "aggs": {
    "group_by_tags": {
      "terms": {
        "field": "tags.keyword",
        "order": {"avg_price": "desc"}
      },
      "aggs": {
        "avg_price": {
          "avg": {"field": "price"}
        }
      }
    }
  }
}
```



#### 4、按照指定价格区间范围进行分，再每组内按照tag进行分组，在计算每组的平均值，按照平均值排序

```javascript
GET /mall/product/_search
{
  "size": 0,
  "aggs": {
    "group_by_price": {
      "range": {
        "field": "price",
        "ranges":[
          {"from": 0, "to": 20},
          {"from": 20, "to": 40},
          {"from": 40, "to": 60}
        ]
      },
      "aggs": {
        "group_by_tags": {
          "terms": {
            "field": "tags.keyword",
            "order": {"avg_price": "desc"}
          },
          "aggs": {
            "avg_price": {
              "avg": {"field": "price"}
            }
          }
        }
      }
    }
  }
}
```



# 二、分布式文档存储系统

## 1、集群

### 1、shard

- 一个node相当于一台服务器
- 建立index，可设置分片和备份，master、replica
- ...

## 2、并发解决方案

### 1、悲观锁

​	在各种情况下都上锁，上锁之后，就只有一个线程操作这一条数据了，不同场景下，上的锁不用，行锁、表锁、读锁、写锁

### 2、乐观锁

​	乐观锁，不加锁，每个线程都可以任意操作，会加版本号version，cas机制

es内部采用_version乐观锁并发控制

#### 1、体现

​	第一次创建一个document的时候，他的_version内部版本号就是1，以后，每次对这个document执行修改或者删除操作，都会对这个 _version版本号自动加1

#### 2、es内部share、replica主备同步时，如何保证数据一致性，如何控制并发的？

1. es的后台，主备同步的请求有很多，都是线程一步的，也就是说，请求之间说乱序的，可能先修改的后到，也可能先修改的先到
2. es内部采用_version版本号，乐观锁机制，每次修改都会比较版本号，当版本号不一致，就会丢弃，总之旧值时不会把新值覆盖的。
3. 想象一下：
   1. 先修改的先到，后修改的后到，ok没问题
   2. 先修改的后到，后修改的先到，es先把值更新会后修改的值，当先修改的到来时，由于版本号不一致，则会被丢弃，纵观整个过程，数据一致性得以保证

#### 3、开发人员怎么控制好并发

1. ##### 基于_version的乐观锁并发控制

   ```javascript
   PUT /test_index/test_type/1?version=2
   {
     "name": "lu2"
   }
   ```

   

2. ##### 基于external version进行并发控制

   ​	es提供了一个feature,你可以不使用它提供的nei bu_version版本号来进行并发控制，可以基于自己维护的一个版本号来进行并发控制。有这个必要吗？假如数据在mysql也有一份，应用系统也维护了一个版本号，这样通过这个版本号也控制es更方便。

   ​	?version=1

   ​	?version=1&version_type=external

   ​	version_type=external，当提供的version比es中_version大的时候，才成功

   ```javascript
   PUT /test_index/test_type/2?version=3&version_type=external
   {
     "name": "lu2
   }
   //[test_type][2]: version conflict, current version [3] is higher or equal to the one provided [3]
   
   PUT /test_index/test_type/3?version=3&version_type=external
   {
     "name": "lu2
   }
   //成功
   ```

3. partial update 内部并发控制

   修改时，es内部逻辑

   1. 先修改文档的元数据对应的field
   2. 文档标记为删除
   3. 复制文档数据，创建新的文档

   以上三部操作，es时怎么保证并发的呢？

   ​	es内部还是会通过_version来控制

   













