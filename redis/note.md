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
    make install PREFIX=/opt/bin/redis  #安装redis，其实就把可执行文件复制到设定目录/opt/src/redis/redis-6.2.1/src
    vi /etc/profile  #添加环境变量
      export REDIS_HOME=/opt/src/redis/redis-6.2.1/src
      export PATH=$PATH:$REDIS_HOME/bin
    source /etc/profile
    cd /opt/src/redis/redis-6.2.1/utils
    # 生成redis实例并配置注册服务（service redis_[port] stop/start/status）:
    #   1、在/etc/init.d目录下生成启动脚本
    #   2、添加开机启动chkconfig
    ./instal_server.sh
      [port]  #端口
      [config_filePath]  #配置文件路径
      [log_filePath]  #日志文件路径
      [date_directory]  #数据目录
      [redis_server_path]  #redis服务执行文件路径
```