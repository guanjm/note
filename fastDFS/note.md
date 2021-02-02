# FastDFS安装  [wiki](https://github.com/happyfish100/fastdfs/wiki)
> ## 使用的系统软件
> | 名称 | 说明 |
> | --- | --- |
> | centos | 7.x |
> | libfastcommon | FastDFS分离出的一些公用函数包 |
> | FastDFS | FastDFS本体 |
> | fastdfs-nginx-module | FastDFS和nginx的关联模块 |
> | nginx | nginx1.15.4 |
> 
> ## 编译环境
> - Centos ```yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel wget vim -y```
> - Debian ```apt-get -y install git gcc g++ make automake autoconf libtool pcre2-utils libpcre2-dev zlib1g zlib1g-dev openssl libssh-dev wget vim```
>
> ## 磁盘目录
> | 说明 | 位置 |
> | --- | --- |
> | 所有安装包 | /usr/local/src |
> | 数据存储位置 | /home/dfs |
> ```
>   mkdir /home/dfs  #创建数据存储目录
>   cd /usr/loacl/src  #切换到安装目录准备下载安装包
> ```
> 
> ## 安装libfastcommon
> ```
>   git clone https://github.com/happyfish100/libfastcommon.git --depth 1
>   cd libfastcommon/
>   ./make.sh && ./make.sh install #编译安装
> ``` 
>
> ## 安装FastDFS
> ```
>   cd ../ #返回上一级目录
>   git clone https://github.com/happyfish100/fastdfs.git --depth 1
>   cd fastdfs/
>   ./make.sh && ./make.sh install #编译安装
>   #配置文件准备
>   cp /etc/fdfs/tracker.conf.sample /etc/fdfs/tracker.conf
>   cp /etc/fdfs/storage.conf.sample /etc/fdfs/storage.conf
>   cp /etc/fdfs/client.conf.sample /etc/fdfs/client.conf #客户端文件，测试用
>   cp /usr/local/src/fastdfs/conf/http.conf /etc/fdfs/ #供nginx访问使用
>   cp /usr/local/src/fastdfs/conf/mime.types /etc/fdfs/ #供nginx访问使用
> ```
> 
> ## 安装fastdfs-nginx-module
> ```
>   cd ../ #返回上一级目录
>   git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1
>   cp /usr/local/src/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs
> ```
>
> ## 安装nginx
> ```
>   wget http://nginx.org/download/nginx-1.15.4.tar.gz #下载nginx压缩包
>   tar -zxvf nginx-1.15.4.tar.gz #解压
>   cd nginx-1.15.4/
>   #添加fastdfs-nginx-module模块
>   ./configure --add-module=/usr/local/src/fastdfs-nginx-module/src/ 
>   make && make install #编译安装
> ```


# 单机部署
> ## tracker配置
> ```
>   vi /etc/fdfs/tracker.conf
>       port=22122  #tracker服务器端口（默认22122，一般不修改）
>       base_path=/home/dfs  #存储日志和数据的根目录
> ```
> 
> ## storage配置
> ```
>   vi /etc/fdfs/storage.conf
>       port=23000  #storage服务端口（默认23000，一般不修改）
>       base_path=/home/dfs  #数据和日志文件存储根目录
>       store_path0=/home/fds  #第一个存储目录
>       tracker_server=[trackerServerIP]:[trackerServerPort]  #tracker服务器IP和端口
>       http.server_port=8888  #http访问文件的端口（默认8888，看情况修改，和nginx中保护一致）
> ```
> 
> ## client测试
> ```
>   vi /etc/fdfs/client.conf
>       base_path=/home/fds
>       tracker_server=[trackerServerIP]:[trackerServerPort]  #tracker服务器IP和端口
>   
>   fdfs_upload_file /etc/fdfs/client.conf [filePath]  #保存后测试，返回id表示成功。
> ```
> 
> ## 配置nginx访问
> ```
>   vi /etc/fdfs/mod_fastdfs.conf
>       tracker_server=[trackerServerIP]:[trackerServerPort]  #tracker服务器IP和端口
>       url_have_group_name=true
>       store_path=/home/dfs
>   
>   vi  /usr/local/nginx/conf/nginx.conf
>       server {
>           listen 8888;  #该端口为storage.conf中http.server_port相同
>           server_name local;
>           location ~/group[0-9]/ {
>               ngx_fastdfs_module;
>           }
>           error_page 500 502 503 504 /50x.html
>           location = /50x.html {
>               root html;
>           }
>       }
> ```
> http://[ip]:[port]/[文件路径]  #测试下载，用外部浏览器访问已上传过的文件

# 启动
> ## 防火墙
> ```
>   systemctl stop firewalld.service  #关闭防火墙
>   systemctl restart firewalld.service  #重启防火墙
> ```
> 
> ## tracker
> ```
>   /etc/init.d/fdfs_trackerd start  #启动tracker服务
>   /etc/init.d/fdfs_trackerd restart  #重启tracker服务
>   /etc/init.d/fdfs_trackerd stop #停止tracker服务
>   chkconfig fdfs_trackerd on #自启动tracker服务
> ```
> 
> ## storage
> ```
>   /etc/init.d/fdfs_storaged start  #启动storage服务
>   /etc/init.d/fdfs_storaged restart  #重动storage服务
>   /etc/init.d/fdfs_storaged stop  #停止动storage服务
>   chkconfig fdfs_storaged on  #自启动storage服务
> ```
>
> ## nginx
> ```
>   /usr/local/nginx/sbin/nginx  #启动nginx
>   /usr/local/nginx/sbin/nginx -s reload  #重启nginx
>   /usr/local/nginx/sbin/nginx -s stop  #停止nginx
> ```
> 
> ## 检测集群
> ```
>   /usr/bin/fdfs_monitor /etc/fdfs/storage.conf  #会显示会有几台服务器，有三台就会显示Storage 1-Storage 3 的详细信息
> ```

# 说明
> ## 配置文件
> tracker_server #有几台服务器写几个
> group_name #地址的名称的命名
> bind_addr #服务器ip绑定
> store_path_count #store_path(数字)有几个写几个
> store_path(数字) #设置几个储存地址写几个 从0开始
>
> ## 可能遇到的问题
> 如果不是root 用户 你必须在除了cd的命令之外 全部加sudo
> 如果不是root 用户 编译和安装分开进行 先编译再安装
> 如果上传成功 但是nginx报错404 先检查mod_fastdfs.conf文件中的store_path0是否一致
> 如果nginx无法访问 先检查防火墙 和 mod_fastdfs.conf文件tracker_server是否一致
> 如果不是在/usr/local/src文件夹下安装 可能会编译出错
> 如果 unknown directive "ngx_fastdfs_module" in /usr/local/nginx/conf/nginx.conf:151，可能是nginx一直是启动的，必须要重启nginx才可以，`nginx -s reload`无效。
> 可通过base_path配置的路径查看日志
>
