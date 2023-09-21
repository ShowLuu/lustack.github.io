Must 里面的都得成立

should里面的成立一个即可，若should里面只有一个，那么就用这一个的条件



term 精确匹配，不会分词

match_phrase 精确匹配

​	会分词，一般是按照空格分

​	目标文档包含，分词后的所有词

​	文档彼此位于相同的位置



使用boost的场景，term、range、boost



Range gt、le 大于小于 y M w d h H m s







script脚本操作

```
//doc['price']
GET /mall/product/_search
{
  "query": {
    "script": {
      "script": {
        "inline": "doc['price'].value > params.num",
        "params": {"num": 25}
      }
    }
  }
}
//ctx._source
POST /mall/product/3/_update
{
  "script": {
    "inline": "ctx._source.price = params.num",
    "params": {"num": 40}
  }
}

PUT /lulog/doc/2
{
  "log_size": 2
}

POST /lulog/doc/_search
{
  "query": {
    "match_all": {}
  },
  "script_fields": {
    "total_size": {
      "script": {
        "inline": "int total=0;for(int i=0; i<doc['log_size'].length;i++){total += doc['log_size'][i];}return total"
      }
    }
  }
}

POST /lulog/doc/_search
{
  "query": {
    "match_all": {}
  },
  "script_fields": {
    "count": {
      "script": {
        "inline": "return doc['log_size'].value + 1"
      }
    }
  }
}
```



聚合：

Metric统计，min、max、sum、avg、stats、extended_stats

Bucket分类，terms，range，date_range，histogram，date_histogram，filter过滤

Pipeline对bucket分类的进行统计，min_bucket，max_bucket，sum_bucket，avg_bucket，stats_bucket，extended_stats_bucket

Matrix计算两个数值型字段之间的关系

```
GET incall_daily-2020.04.24/doc/_search
{
  "aggs": {
    "asdjhasd": {
      "matrix_stats": {
        "fields": ["applause_count", "answer_count"]
      }
    }
  }
}
{
	"name": "applause_count",	//字段名称
	"count": 154,	//字段样本数量
	"mean": 44.31818181818182,	//平均值
	"variance": 276.04842543077837,	//方差，偏离平均值的程度
	"skewness": -1.60794152400977,	//偏度，在平均值附近的非对称分布情况的量化
	"kurtosis": 5.006387495325678,	//峰度，分布的形状的量化
	"covariance": {	//协方差，描述一个字段数据随另一个字段数据变化程度的矩阵
		"applause_count": 276.04842543077837,
		"answer_count": 290.8722519310755
	},
	"correlation": {	//相关性，描述两个字段数据之间的分布关系，其协方差矩阵取值为[-1, 1]
		"applause_count": 1.0,
		"answer_count": 0.9397723506362066
	}
}, {
	"name": "answer_count",
	"count": 154,
	"mean": 53.48051948051948,
	"variance": 347.035565741448,
	"skewness": -2.2011119165278625,
	"kurtosis": 6.583666847748493,
	"covariance": {
		"applause_count": 290.8722519310755,
		"answer_count": 347.035565741448
	},
	"correlation": {
		"applause_count": 0.9397723506362066,
		"answer_count": 1.0
	}
}
```



如果是聚合，需要过滤数据，建议使用filter，不要使用query

为啥？filter 只会匹配文档是不是我要的，query匹配好之后，还多了一个相关性算分的过程，因此filter效率更高

```
GET incall_daily*/doc/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "match": {
            "parent_id": "17871"
          }
        }
      ]
    }
  }, 
  "aggs": {
    "a1": {
      "date_histogram": {
        "field": "create_time",
        "interval": "2d"
       },
       "aggs": {
         "a2": {
           "stats": {
             "field": "applause_count"
           }
         }
       }
    }
  }
}
GET incall_daily-2020.04.24/doc/_search
{
  "aggs": {
    "f1": {
      "filter": {
        "term": {
          "user_id": "17871"
        }
      },
      "aggs": {
        "a1": {
          "date_histogram": {
            "field": "create_time",
            "interval": "2d"
          },
          "aggs": {
            "a2": {
              "terms": {
                "field": "applause_count"
              }
            }
          }
        }
      }
    }
  }
}
```



# 二、查询篇

## 1、

### 1、高亮查询

```
GET callcenter/_search
{
  "query": {
    "match": {
      "content": "天翼"
    }
  },
  "size": 30,
  "highlight": {
    "pre_tags": "<span>", 
    "post_tags": "</span>", 
    "fields": {
      "content": {
        "fragment_size": 20,			//从content内容的前20个字来找高亮字段
      }
    }
  }
}
```



### 2、查询字符串查询

```
query_string，只有 AND OR，且必须是大写
simple_query_string，+与 |或 -非 () * 

GET /callcenter/_search
{
  "query": {
    "query_string": {
      "fields": ["title", "content"], 
      "query": "天翼 AND (骚扰 OR 商务)"
    }
  }
}
GET /callcenter/_search
{
  "query": {
    "query_string": {
      "fields": ["title", "content"], 
      "query": "(商务 OR 直播) AND 商务"
    }
  }
}

GET callcenter/_search
{
  "query": {
    "simple_query_string": {
      "query": "-商务 + -工号 + -外勤 + -网吧 + -天翼",
      "fields": ["title"]
    }
  }
}

相关性
GET callcenter/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "content": "天翼商务"
        }
      },
      "negative": {
        "match": {
          "content": "商务"
        }
      },
      "negative_boost": 0.2
    }
  },
  "size": 50
}
```



### 3、复合查询

```
该查询实现和上面的查询一样的效果，看得出，代码写的贼麻烦

GET callcenter/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "bool": {
            "must_not": [
              {"match": {"title": "商务"}},
              {"match": {"title": "工号"}},
              {"match": {"title": "外勤"}},
              {"match": {"title": "网吧"}},
              {"match": {"title": "天翼"}}
            ]
          }
        },
        {
          "bool": {
            "must_not": [
              {"match": {"content": "商务"}},
              {"match": {"content": "工号"}},
              {"match": {"content": "外勤"}},
              {"match": {"content": "网吧"}},
              {"match": {"content": "天翼"}}
            ]
          }
        }
      ]
    }
  }
}
```



### 4、精确查找

```

GET callcenter/_search
{
  "query": {
    "term": {
      "title": {
        "value": "商务"
      }
    }
  }
}
GET callcenter/_search
{
  "query": {
    "match_phrase": {
      "title": "商务"
    }
  }
}
GET callcenter/_search
{
  "query": {
    "terms": {
      "title": [
        "电信",
        "号码"
      ]
    }
  }
}
```



### 5、分页查询

```
GET article/_search
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "date": {
        "order": "desc"
      }
    }
  ],
  "from": 20, 
  "size": 20
}

滚动翻页
GET article/_search?scroll=1m
{
  "query": {
    "match_all": {}
  },
  "sort": [
    {
      "date": {
        "order": "desc"
      }
    }
  ], 
  "size": 10
}
GET _search/scroll
{
  "scroll": "1m",
  "scroll_id": "DnF1ZXJ5VGhlbkZldGNoBQAAAAAABdUMFk5uSzVIbGRuU1FTb1RoT0x5dTVyM2cAAAAAAAXVDRZObks1SGxkblNRU29UaE9MeXU1cjNnAAAAAAAF1Q4WTm5LNUhsZG5TUVNvVGhPTHl1NXIzZwAAAAAABdUPFk5uSzVIbGRuU1FTb1RoT0x5dTVyM2cAAAAAAAXVEBZObks1SGxkblNRU29UaE9MeXU1cjNn"
}
```



### 6、聚合查询

```
GET incall_daily-2020.04.24/_search
{
  "aggs": {
    "f": {
      "range": {
        "field": "create_time",
        "ranges": [
          {
            "from": "2020-04-23T00:00:00.000Z"
          }
        ]
      }, 
      "aggs": {
          "d1": {
            "date_histogram": {
              "field": "create_time",
              "interval": "1d",
              "order": {
                "_key": "desc"
              }
            },
            "aggs": {
              "d2": {
                "terms": {
                  "field": "order_type.keyword",
                  "order": {
                    "d3": "desc"
                  }
                },
                "aggs": {
                  "d3": {
                    "sum": {
                      "field": "answer_count"
                    }
                  }
                }
              }
            }
          }
        }
    }
  }
}
```

### 7、建议查询

```
精准程度上(Precision)看： Completion >  Phrase > term
速度上，Completion是最快的

自动补全设计：优先取Completion，依次...

POST /lu_article/_search
{
  "_source": ["title", "descript", "create_time"],
  "suggest": {
    "s1": {
      "prefix": "cento",
      "completion": {
        "field": "suggest",
        "fuzzy": {
          
        }
      }
    },
    "s2": {
      "text": "elasticseqrch mybatls mysal",
      "phrase": {
        "field": "descript",
        "highlight": {
          "pre_tag": "<em>",
          "post_tag": "</em>"
        }
      }
    },
    "s3": {
      "text": "elasticseqrch mybatls mysal",
      "term": {
        "field": "descript"
      }
    }
  }
}


##completion创建字段，插入值，自动补全，suggest可以是字符串、对象、数组，weight选填
"suggest": {
	"type": "completion",
  "analyzer": "ik_max_word"
 },
 PUT /lu_article/_doc/1
{
  "suggest": [
    {
      "input": "lucene solr",
      "weight": 1
    },
    {
      "input": "lucene so cool",
      "weight": 4
    },
    {
      "input": "lucene elasticsearch",
      "weight": 3
    }
  ]
}
POST /lu_article/_search
{
  "_source": ["title", "descript", "create_time", "suggest"],
  "suggest": {
    "s1": {
      "prefix": "luce",
      "completion": {
        "field": "suggest"
      }
    }
  }
}
          
          
```

