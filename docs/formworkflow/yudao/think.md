[参考](https://cloud.iocoder.cn/bpm/)

## 流程表单

### 如何实现动态的流程表单

- 官网：https://github.com/JakHuang/form-generator
- JSON表单参数对照表：https://github.com/JakHuang/form-generator/issues/46
- 源码copy项目中：components、icons、style、utils、Views
- 可以更改 views bpm form .vue源码，增加字段属性
- 表单的配置 conf
- 表单项的数组 fields

![image-20230323161735783](./images/02.png)



### ![image-20230323194619313](./images/03.png)





## 流程模型

### 如何实现流程模型的新建

![image-20230323202549050](./images/04.png)





### 如何实现流程模型的流程图设计

- 官网：https://github.com/miyuesc/bpmn-process-designer
- 设计体验：https://miyuesc.github.io/process-designer/
- bpmn.js中文全面进阶文档，可配合代码食用~ vue2：https://github.com/miyuesc/bpmn-process-designer vue3：https://github.com/moon-studio/vite-vue-bpmn-process

![image-20230323210101665](./images/05.png)



### 如何实现流程模型的分配规则

![image-20230323215909127](./images/06.png)





### 如何实现流程模型的发布

![image-20230324000337972](./images/07.png)



## 流程定义

### 如何实现流程定义的查询

![image-20230324000805446](./images/08.png)





### 如何实现流程的发起

![image-20230324001639438](./images/09.png)



### 如何实现流程的取消

![image-20230324005500263](./images/10.png)



## 流程任务

### 如何实现流程的任务分配

![image-20230324011044160](./images/11.png)

### 如何实现会签、或签任务

![image-20230324012723216](./images/12.png)

- [会签](https://cloud.iocoder.cn/bpm/#_3-1-%E4%BC%9A%E7%AD%BE)

  - 定义：同一个审批节点设置多个人，如ABC三个人，三人会同时收到审批，会创建3个审批任务，全部统一以后，审批才可到下一个节点
  - 多实例 -> 回路特征 -> 并行多重事件 -> 完成条件 `${ nrOfCompletedInstances== nrOfInstances }`

  ![image-20230324011644902](./images/13.png)

- 或签

  - 定义：同一个审批节点设置多个人，如ABC三个人，三人会同时收到审批，会创建3个审批任务，只要其中任意一人审批即可到下一个节点，其他的自动取消
  - 多实例 -> 回路特征 -> 并行多重事件 -> 完成条件 `${ nrOfCompletedInstances== 1 }`

  ![image-20230324011928897](./images/14.png)

  

### 如何实现待办、已办列表

![image-20230324013456009](./images/15.png)

![image-20230324013740317](/Users/zhanglu/Library/Application Support/typora-user-images/image-20230324013740317.png)

### 如何实现任务的审批通过、不通过

![image-20230324014956096](./images/16.png)

![image-20230324015347099](./images/17.png)

### 如何实现流程的审批记录

![image-20230324015915605](./images/18.png)



### 如何实现流程的流程图的高亮

![image-20230324091021455](./images/19.png)



### 如何实现工作流的短信通知

![image-20230324091111920](./images/20.png)





### 如何实现OA请假的发起

![image-20230324091212254](./images/21.png)

### 如何实现OA请假的审批

![image-20230324091323077](./images/22.png)



