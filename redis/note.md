# 缓存产生的来由
> 1. 数据存储
>   - 持久化：存储在磁盘上
>   - 读写操作：磁盘I/O
> 2. 文件存储原理
>   - 文件数据：存储在磁盘上
>   - 读写操作：通过程序读写磁盘（磁盘I/O）
> 3. 硬件问题
>   - 磁盘
>       - 寻址：ms级别
>       - 带宽：GB/MB级别
>   - 内存
>       - 寻址：ns级别
>       - 带宽：GB级别
>   - 磁盘与内存性能差距上很大
> 4. 常见数据库原理（本质上：避免磁盘I/O）
>   - 机械硬盘：512byte一扇区
>   - 常见系统：直接读取4k数据：就算只读1byte数据，都会直接读取4k数据。数据库对此优化，数据按4k存放
>   - 真实数据：存储在磁盘上，查找数据，需要全量数据读取出来。
>   - 索引数据：存储在磁盘上，通过索引区分业务数据（数据表，字段索引），通过索引数据查找真实数据：避免全量数据读取。
>   - b+树：存储在内存上，运算：快速定位索引数据。
>   - 数据量大时瓶颈：
>       1. 并发小，内存足够容纳b+树，查询走索引：查操作不慢，增删改操作慢（需要调整索引）
>       2. 并发大，就算内存足够容纳b+树，查询走索引：查操作因为并发大的原因，也会存在大量磁盘I/O
> 5. 内存数据库（SAP的HANA）
>   - 缺点：贵
>   - 导火线：如果价格低，不会有缓存中间件的诞生。
> 6. 现代计算机体系：
>   - 冯诺依曼（计算机结果）：运算器，控制器，存储器，输入设备，输出设备
>   - 网络：以太网，TCP
> 7. 常见数据库解决方案：
>   - 避免磁盘I/O：把热点数据继续往内存里存放
>   - 解决方案：在数据库应用上，加多一层内存数据库
>   - 内存数据库：redis，memcache

# redis和memcache
> - 功能上
>   - redis
>       - value数据类型：支持string（字符串），list（列表），hash（散列），set（集合），sorted set（有序集合）
>       - 数据结构：原生支持
>       - 操作数据（运算在redis，运算向数据移动）：原生支持，直接通过redis提供的函数直接操作
>       - 带宽（小）：直接读写value数据结构上的某个值
>   - memcache
>       - value数据类型：string
>       - 数据结构：通过存储json字符串能满足各种数据类型需求
>       - 操作数据（运算在代码层）：需要在客户端（代码层）实现json各种数据类型的转化以及操作
>       - 带宽（大）：读写整个value数据
> - 性能上
>

# redis安装
```shell script
    mkdir /opt/src/redis  #创建redis源代码目录
    cd /opt/redis
    curl -O https://download.redis.io/releases/redis-6.2.1.tar.gz  #下载redis源代码
    tar xf redis-6.2.1.tar.gz
    cd /opt/src/redis/redis-6.2.1
    vi README.md  #查看redis安装说明
    yum install make gcc
    make  #编译，该目录下有Makefile文件才能编译，编译后src目录下生成可执行文件
      make distclean  #make失败时清除文件
    make install PREFIX=/opt/bin/redis  #安装redis，其实就把可执行文件复制到设定目录/opt/bin/redis
    vi /etc/profile  #添加环境变量
      export REDIS_HOME=/opt/bin/redis
      export PATH=$PATH:$REDIS_HOME/bin
    source /etc/profile
    cd /opt/src/redis/redis-6.2.1/utils
    # 生成redis实例并配置注册服务（service redis_[port] stop/start/status）:
    #   1、在/etc/init.d目录下生成启动脚本redis_[port]
    #   2、添加开机启动chkconfig
    ./instal_server.sh
      [port]  #端口
      [config_filePath]  #配置文件路径
      [log_filePath]  #日志文件路径
      [date_directory]  #数据目录
      [redis_server_path]  #redis服务执行文件路径
```

# 知识补充（I/O）
> - BIO（阻塞IO）
>   - 阻塞同步：用户态使用多线程，对每个fd资源就绪判定（瓶颈：需要多个线程等待，socket系统调用上问题）
> - NIO（非阻塞）
>   - 非阻塞同步：用户态使用循环对所有的fd资源就绪判定（瓶颈：循环的用户态和内核态切换）
>   - poll：内核态使用循环对所有的fd资源就绪判定，每次调用需要把所有的fd作为参数（瓶颈：大量参数数据的传输）
>   - epoll：内核态构建一个红黑树来维护所有fd，通过中断来触发fd资源就绪
> - AIO（linux目前未实现，window已实现）
> - 零拷贝（sendfile（out_fd,in_fd））
>   - out_fd：必须是一个类型mmap函数的文件描述符，指向真实文件，不能是socker和管道
>   - in_fd：必须是一个socket
>   - read/write原理：硬盘->内核->用户->内核->相关协议引擎（4次）
>   - sendfile原理：硬盘->内核->相关协议引擎（2次）
> - 存映射文件（mmap）
>   - 将一个文件或者其他对象映射到进程空间，实现文件磁盘地址和进程虚拟地址空间中的一段虚拟地址映射关系
>   - 进程直接采用指针的方式读写操作这段内存，系统会自动写回脏页到硬盘上，避免了read，write的系统调用。

# redis常用
> - string 
>   - key：type，encoding
>   - string 字符串
>       - set [key] [value] [EX seconds|PX milliseconds] [NX|XX]  #EX：过期时间（秒），PX：过期时间（毫秒），NX：key不存在才设置，XX：key存在才设置
>       - get [key] [value]
>       - mSet [[key] [value] ...]  #批量设置
>       - mGet [key] [key]  #批量查询
>       - append [key] [value]  #追加
>       - setRange [key] [offset] [value]
>       - getRange [key] [start] [end]
>       - strLen [key]  #获取value长度（字节数）
>   - integer 数值
>       - incr [key]
>       - incrBy [key] [increment]
>       - incrByFloat [key] [increment]
>       - decr [key]
>       - decrBy [key] [decrement]
>       - 场景
>           - 抢购，秒杀，点赞，评论（数据精确度不高的），规避并发下对数据库的事务操作
>   - bit 二进制
>       - setBit [key] [offset] [value]  #设置二进制，其中[offset]为二进制序号
>       - bitPos [key] [bit:0|1] [start] [end]  #返回value的二进制为[bit]的第一个二进制序号，其中[start]和[end]是value的字节序号，返回的值为整个value的二进制序号，而不是在指定范围内的二进制序号
>       - bitCount [key] [start] [end]  #返回value的二进制为‘1’的数量，其中[start]和[end]是value的字节序号
>       - bitOp [operation:and|or] [destKey] [key...]  #对多个key做位运算，[operation]为位运算符，[destKey]为目标key
>       - 场景
>           - 用户每天登录记录，key为用户维度，value的二进制位标记为‘1’时为某天已登录，可记录用户全部登录记录。
>           - 用户活跃度，key为日期维度，value的二进制位标记为‘1’时为某个用户已登录（用户与二进制位作映射），可记录某天全部用户登录记录。
> - list 列表（双向链表，插入有序）
> - key：type，encoding，head，tail
>       - lPush [key] [value...]  #链表前（左）插入
>       - rPush [key] [value...]  #链表后（右）插入
>       - lPop [key] [count] #链表前（左）弹出
>       - rPop [key] [count] #链表后（右）弹出
>       - lRange [key] [start] [end]
>       - lIndex [key] [index]  #获取链表目标序号的元素，nil
>       - lSet [key] [index] [element]  #设置链表目标序号的元素，index out of range
>       - lRem [key] [count] [element]  #移除链表目标元素，[element]目标元素，[count]删除的数量(可正负，正：前（左）开始，负：后（右）开始)
>       - lInsert [key] [before|after] [pivot] [element]  #链表前（左）开始以第一个[pivot]元素（精确元素，非链表序号）为支点，在[before|after]的位置，添加一个[element]
>       - lLen [key]
>       - lTrim [key] [start] [end] #去掉链表从[start]到[end]之外的元素，只保留链表从[start]到[end]的元素
>       - blPop [key...] [timeout]  #阻塞弹出，[timeout]超时时间，0时永久
>       - 场景
>           - 栈，同向链表操作，lPush + lPop
>           - 队列，反向链表操作，lPush + rPop
>           - 数组，lIndex + ISet
>           - 阻塞队列，blPop
> - hash 散列
>       - hSet [key] [[field] [value]...]
>       - hGet [key] [field...]
>       - hDel [key] [field...]
>       - hLen [key]
>       - hExists [key] [field]
>       - hKeys [key]  #所有field值
>       - hVals [key]  #所有value值
>       - hGetAll [key]  #所有field和value值
>       - hIncrBy [key] [field] [increment]
>       - 场景
>           - 商品详情页（点赞，收藏）
> - set 集合（无序，去重）
>       - sAdd [key] [member...]  #添加
>       - sPop [key] [count]  #随机弹出
>       - sMembers [key]  #获取所有
>       - sCard [key]  #获取数量
>       - sRem [key] [member...]
>       - sInter [key...]  #多个set交集
>       - sInterStore [destination] [key...]  #多个set交集，并储存在key为[destination]的集合里
>       - sUnion [key...]  #多个set并集
>       - sDiff [key...]  #多个set的差集，按key的传参顺序来决定左差还是右差
>       - sRandMember [key] [count]  #随机，[count]随机数的数量（正：不能超过集合数量，不可重复，负：可超出集合数量，可重复）
>       - 场景
>           - 集合操作
>           - 随机事件，抽奖
> - sorted_set 有序集合（有序，去重）
>       - 底层数据结构
>           - skipList 跳跃表
>       - 排序：score，排序依据。score相同时，以名称的字典顺序。物理排序：左小右大（从小到大）。当分值变化，物理排序才变化。
>       - zAdd [key] [[score] [member]...]
>       - zRange [key] [start] [end] [withScores]
>       - zRangeByScore [key] [mix] [max]
>       - zScore [key] [member]  #数据的分值
>       - zRank [key] [member]  #数据的排名
>       - zIncrBy [key] [increment] [member]  #提升数据分值
>       - zUnionStore [destination] [keyNumber] [key...] [weights [weight...]]  #交集，[keyNumber]key的数量，[key...]多个集合，[weight...]多个集合的依次权重（默认都为1），[aggregate [sum|min|max]]分值合并的统计（默认sum）
>       - 场景
>           - 榜单
>           - 集合操作，需要权重/聚合命令
> - pubsub 发布/订阅
>       - publish [channel] [message]  #发布消息
>       - subscribe [channel...]  #订阅频道
>       - pSubscribe [pattern...]  #订阅匹配频道
>       - unsubscribe [channel...]  #取消订阅
>       - pUnsubscribe [pattern]  #取消订阅匹配频道
>       - pubsub [subCommand] [argument]  #分析发布/订阅
>       - 场景
>           - IM（即时通讯）
>               - 发送消息 client(IM APP) => publish => redis-server
>               - 实时消息 redis-server => subscribe => client(IM APP)
>               - 历史消息
>                   - 近期内 redis-server => subscribe => redis-server(sorted set)，score：时间，member：内容
>                   - 更多历史数据 redis-server => subscribe => kafka => database
> - transaction 事务
>       - multi  #标记事务开始，只做标记，不执行命令
>       - exec  #执行事务，执行失败回滚。当多个客户端同时发起事务，谁先执行exec，谁事务先执行。
>       - discard  #放弃事务
>       - watch [key...]  #观察[key]是否被更改，直到执行multi/exec命令，若有更改，事务不执行
>       - unwatch  #忘记之前所有的[key]
>       - 场景
>           - client1 ```multi get k1 exec``` 
>           - client2 ```multi del k1 exec```
>           - status1 ```(1)multi (2)multi (2)del k1 (1)get k1 (2)exec (1)exec```，client1 获取nil（先client2，再client1）
>           - status2 ```(1)multi (2)multi (2)del k1 (1)get k1 (1)exec (2)exec```，都执行成功（先client1，再client2）
>

# redis
> - ```type``` 数据类型
>   - 通过```type [key]```命令，返回当前这个key的value所属数据类型，5大类型（string，list，hash，set，sorted set）
> - ```object [subcommand]```
>   - ```encoding``` 编码类型
> - 支持正负索引：“ok!”字符串的索引，‘o’=[0|-3],‘k’=[1|-2],‘!’=[2|-1]，其中0为正序起始，-1为倒序起始
> - 二进制安全
>   - redis通过字节流来存储数据
>   - 字符串：在终端```set [key] [中文]```，再```get [key]```时，返回的是十六进制，不过用客户端```redis-cli --raw```时，会自动转译为中文（字符集跟当前终端设置的字符集有关）
>   - 数值：不同的语言存储的数值字节数不同，所以redis直接通过一个字节记录一位数值。（9999，strLen为4）
> - 原子性
>   - ```
>       mSetNX key1 1 key2 2 => 1
>       mGet key1 key2 => 1 2
>       mSetNX key2 22 key3 3 => 0
>       mGet key1 key2 key3 => 1 2 nil
>     ```  
>       mSetNX命令中key3操作失败，导致key3操作也失败，整个操作都会操作失败
>

# pipelining(管道)
> - 客户端-服务端模型，TCP请求/响应协议
> - 能实现处理新的请求即使旧的请求还未被响应=>多个命令发送到服务器，不用等待回复，最后在一个步骤中读取该答复。
> - POP3协议已实现支持这个管道功能，大大加快了从服务器下载新邮件的过程
> - 使用管道发送命令时，服务器讲被迫回复一个队列答复，占用很多内存。因此发大量的命令时，最好按照合理数量分批次的处理。
> - ```shell script
>       echo -e "set key1 1\nincr key1\nget key1" | nc localhost 6379
>   ```

# redis大量数据插入
> - Luke协议
>   - 常规redis命令集文件（redis-command.file） 
>   - ```（cat redis-command.file；sleep 10）| nc localhost 6379 > /dev/null```不可靠方式，不能检查错误
>   - ```cat redis-command.file | redis-cli --pipe```pipe模式（2.6开始），有效输出错误
> - redis协议
>   - 尽可能快地发送数据到数据库
>   - 读取数据同时解析它
>   - 一旦没有更多数据的输出，它就会发一个特殊的ECHO命令，后面跟着20个随机的字符。
>   - 一旦这个特殊命令发出，收到的答复开始匹配这20个字符。当匹配成功就退出。

# 事务（不完整，不支持回滚）
> - multi 命令只标记事务开始，不会执行，（写入的命令，都放到一个缓存队列里）
> - exec 多个事务，谁先执行exec，谁事务里的命令优先执行。（拿取缓存队列里的命令依次执行）
> - watch 检测目标key的值是否有改变（ABA也算），若有改变接下一次事务不执行

# module
> - redisBloom 布隆过滤器
> - ```redis-server --loadmodule [moduleAbsolutePath] [configPath]```

# 延伸
> - 过滤器
>   - bloom filter
>       - 原理：一个随机数，k个hash函数，一个一维（0|1）数组。随机数经过k个hash函数的映射，得到k个索引，在数组中把k个位置置为1。
>       - 缺点：1、无法删除，2、误报（不存在误以为存在，k个hash同时碰撞）
>   - counting bloom filter
>       - 原理：在bloom filter基础上，（0|1）数组变为counter数组，添加时counter+1，删除时counter-1。
>   - cuckoo filter布谷鸟过滤器
>       - 原理：两张表，两个hash函数，当新数据加时，计算这个数据在两张表的位置，如果其中一张表的数据为空，则存入表中。  
>           当两张表都不为空，随机踢出其中一个表上原有数据并存入，这个原有数据通过另外的hash函数计算另外一张表的位置，循环操作直到能存入数据。  
>           若有数据不断提出，形成循环，代表达到极限，需要将hash函数优化或hash表扩容。