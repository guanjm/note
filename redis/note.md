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
> string 
>   - string 字符串
>       - set [key] [value] [EX seconds|PX milliseconds] [NX|XX]  #EX：过期时间（秒），PX：过期时间（毫秒），NX：key不存在才设置，XX：key存在才设置
>       - get [key] [value]
>       - mSet [[key] [value]] [[key] [value]]  #批量设置
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
>           - 抢购，秒杀，详情页，点赞，评论（数据精确度不高的），规避并发下对数据库的事务操作
>   - bit 二进制
>       - setBit [key] [offset] [value]  #设置二进制，其中[offset]为二进制序号
>       - bitPos [key] [bit:0|1] [start] [end]  #返回value的二进制为[bit]的第一个二进制序号，其中[start]和[end]是value的字节序号，返回的值为整个value的二进制序号，而不是在指定范围内的二进制序号
>       - bitCount [key] [start] [end]  #返回value的二进制为‘1’的数量，其中[start]和[end]是value的字节序号
>       - bitOp [operation:and|or] [destKey] [key...]  #对多个key做位运算，[operation]为位运算符，[destKey]为目标key
>       - 场景
>           - 用户每天登录记录，key为用户维度，value的二进制位标记为‘1’时为某天已登录，可记录用户全部登录记录。
>           - 用户活跃度，key为日期维度，value的二进制位标记为‘1’时为某个用户已登录（用户与二进制位作映射），可记录某天全部用户登录记录。
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
