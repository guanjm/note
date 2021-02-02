# nginx功能
> - http服务器
> - 代理功能
> - 负载均衡
> - URL hash
> - 节省ip地址
> - 软防火墙

# 反向&正向代理
> - 正向代理
>   - 目标端（服务器） 通过服务器 代理访问所要资源
> - 反向代理
>   - 目标端（服务器） 通过服务器 代理接收或响应所要请求

# nginx.conf
> 1. user [userName] [groupName]  **指定运行用户或者用户组**  
> 2. worker_processes [count]  **worker进程数，通常与CPU的数量相同**  
> 3. error_log [filePath(.log)]  **全局错误日志路径**  
> 4. pid [filePath(.pid)]  **记录当前启动nginx的进程id**  
> 5. events {}
>   - worker_connections [count]  **单个worker进程最大并发连接数**  
> 6. http {}
>   - include [filePath]  **导入其他配置文件**
>   - include mime.types  **导入mime配置文件，用于浏览器识别**
>   - default_type [contentType]  **默认的内容类型[application/octet-stream（下载）]**
>   - log_format main [日志格式]  **设定日志**
>   - access_log [filePath]  **访问日志**
>   - rewrite_log [on/off]  **重写日志**
>   - sendfile [on/off]  **是否调用sendfile函数（zero copy方式）来输出文件**
>       - on 用来进行下载等应用磁盘io负载应用
>           - 磁盘io：直接通知内核去把文件复制到网卡，减少经过程序内存拷贝
>           - 网络io：异步网络io，发送文件速度很快（当下游性能不足时，存在下游消费不及时，数据被抛弃：图片加载到一般）
>       - off 平衡磁盘和网络IO处理速度，降低系统的uptime
>   - keepalive_timeout [second]  **连接超时时间**
>   - tcp_nopush [on/off]  **tcp流处理，优化tcp传输**
>   - tcp_nodelay [on/off]
>   - gzip [on/off] **gzip压缩，（html，js空格，减少网络带宽），需要浏览器和服务器支持**
>   - gzip_min_length [size] **超过这个大小才开启压缩**
>   - gzip_comp_level [level] 1-10  **压缩级别，越大压缩越好，同时越消耗cpu**
>   - gzip_types [content-type] **gzip压缩目标类型**
>   - gzip_vary [on/off]  **给CDN和代理服务器使用**
>   - upstream [serverName] {}  **设定实际服务器列表**
>       - server [ip:port]
>           - **默认轮询**
>           - [weight]=[number]  **weigth权重，不能加空格**
>           - down  **不参与负载**
>           - backup  **当其他非backup机器down或忙时，参与负载**
>           - max_conns [count] **最大连接数**
>           - max_fails [count] **失败多少次踢出**
>           - fail_timeout [times]  **踢出后等待时长，等待过后继续接收请求，如果还是失败继续循环**
>   - server {}  **虚拟主机**
>       - listen [port]  **监听端口**
>       - server_name [hostname]  **虚拟主机访问名**
>       - index [filePath(.html)]  **首页访问路径**
>       - root [fileDir]  **webapp目录**
>       - charset [charsetType]  **字符集类型**
>       - proxy_connet_timeout [second]  **代理连接超时时间**
>       - proxy_send_timeout [second]  **代理发送超时时间**
>       - proxy_read_timeout [second]  **连接成功后，代理接受超时时间**
>       - proxy_buffer_size [size]  **保护用户头信息的缓存区大小**
>       - proxy_buffers [number] [size]
>       - proxy_busy_buffers_size [size]  **高负荷下缓冲大小（proxy_buffers\*2）**
>       - proxy_temp_file_write_size [size]  **缓存文件夹大小，当大于此值，从upstream服务器传**
>       - client_max_body_size [size]  **客户端请求最大值**
>       - client_body_buffer_size [size]  **缓冲区客户端请求最大值**
>       - proxy_set_header [key] [value]  **代理头部设置**
>           - Host $host;
>           - X-Forwarder-For $remote_addr
>       - location [regexp] {}  **虚拟目录，多个location时，会优先匹配regexp更进准匹配的location，不按location编写顺序**
>           - root [fileDir]  **静态文件-静态文件根目录，多个location时，只能有一个**
>           - alias [fileDir] **静态文件-静态文件根目录，需要多个虚拟目录时，使用此参数**
>           - index [filePath]  **静态文件-默认访问页面**
>           - autuoindex [on/off]  **开启自动索引，自动生成当前目录列表**
>           - expires [times]  **静态文件-静态文件过期时间**
>           - stub_status [on/off]  **开启用于查看基本的服务器信息，一般单独location**
>           - access_log  [on/off]  **访问日志**
>           - auth_basic [authName]  **基于http basic协议认证**
>           - auth_basic_user_file [authFilePath]  **用户认证密码文件路径**
>               - ```
>                   httpd-tools
>                   yum install httpd
>                   htpasswd -c -d /usr/local/users [username]
>                   生成用户认证密码文件
>                 ```
>           - deny []  **禁止访问，（ip，ip段）**
>           - allow []  **允许访问**
>           - proxy_pass [url]  **反向代理-反向代理路径，可配置upstream**
>               - 当代理外部链接时，有可能出现302，导致客户端直接302重定向，nginx无法真实代理请求数据
>                ```
>                 location / {
>                      proxy_pass http://127.0.0.1:8081;
>                      proxy_intercept_errors on;
>                      error_page 301 302 307 = @handle_redirects;
>                  }
>                  location @handle_redirects {
>                      set $saved_redirect_location '$upstream_http_location';
>                      proxy_pass $saved_redirect_location;
>                  }
>                 ```
>           - proxy_cache [cacheName]  **代理缓存，把下游请求数据缓存起来**
>       - proxy_cache_path [fileDir] [level]=[] [keys_zone]=[cacheName]  **本地缓存，使用磁盘缓存**
>       - error_page [code] [filePath]  **异常页面**

# session同步
> - tomcat  + memcache插件（需要在tomcat配置文件配置）
>       - 当出现session无法同步时，有可能是两台服务器时间不一致，导致session过期
>


# openssl