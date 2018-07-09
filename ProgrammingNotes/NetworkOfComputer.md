# 计算机网络

## 1. 应用层

### 1.1 HTTP

`HTTP`是超文本传输协议的缩写，是基于`TCP/IP`通信协议来传输数据。

**HTTP1.1新增**

1. 长连接，并默认启用，即当`Connection`字段为`Keep-Alive`时，Response后不会立即关闭而是会等待一段时间。
2. `HOST`域，且必须传送，不传送会报400错误
3. `Range`域，表示只请求资源的一个部分，其值为请求的长度范围或位置，即可以据此实现断点续传功能，服务器增加了`Content-Range`标明了这次传送的范围和总长度。
4. `Cache-Control`域，针对的是`HTTP1.0 Expire`由于服务器和客户端时间不一致导致的问题

**HTTP2将新增**

1. 多路复用请求；
2. 对请求划分优先级；
3. 压缩HTTP头；

**特点**

无状态，所以应答快。   
`HTTP1.0`使用非持续连接，`HTTP1.1`使用持续连接，一个连接可以传送多个`Web`对象。
`HTTP1.0`只有`GET`、`POST`、`HEAD`三种请求类型，其他请求都是`HTTP1.1`新增的。

**HTTP工作流程**

一般为四个步骤：

1. 用户点击超链接或浏览器直接访问
2. 客户端主动向服务器建立TCP连接并发送Request给服务器
3. 服务器接收请求并发送Response给客户端，若connection模式为close则立即关闭TCP，若为Keepalive则会等待一段时间再关闭
4. 客户端接收消息并显示

**HTTP之Request**

`Request`报文分为四个部分：

第一部分：请求行，包括请求类型，URI，协议版本    
第二部分：请求头部，用来说明服务端要使用的附加信息，如HOST，User-Agent，Content-Type、Content-Length、Accept，Refer，Accept-Encoding，Accept-Language   
第三部分：空行
第四部分：正文

**HTTP之Response**

`Response`报文分为四个部分：

第一部分：响应行，包括协议版本，状态码，状态消息    
第二部分：响应头部，用来说明客户端要使用的附加信息，如Date，Content-Type、Content-Length
第三部分：空行
第四部分：正文

**HTTP之状态码**

1xx：指示信息--表示请求已接收，继续处理   
2xx：成功--表示请求已被成功接收、理解、接受    
3xx：重定向--要完成请求必须进行更进一步的操作  
4xx：客户端错误--请求有语法错误或请求无法实现   
5xx：服务器端错误--服务器未能实现合法的请求   

常用的：   
200 Ok //成功   
400 Bad Request //请求语法有错   
403 Forbidden  //服务器收到请求，但拒绝服务   
404 Not Found   //请求资源不存在    
500 Internal Server Error  //服务器未知错误   
503 Server Unavailable   //服务不可用，一段时间后可能恢复正常   

**HTTP之请求方法**

HTTP1.0定义了三种请求方法：`GET`、`POST`和`HEAD`方法。   
HTTP1.1新增了五种请求方法：`OPTIONS`、`PUT`、`DELETE`、`TRACE`和`CONNECT`方法。

- GET 请求页面信息，参数位于URL后
- POST 请求页面信息，参数位于请求Body中
- HEAD 同GET，但只返回请求头
- PUT 添加或更新数据
- DELETE 删除数据
- TRACE 回显请求，主要用于测试或诊断
- CONNECT HTTP1.1预留方法，打算用于管道代理服务器
- OPTIONS 请求服务端可以接受的其他请求方法

**HTTP之缓存**

强制缓存，`HTTP1.0`通过`Expire`完成，`HTTP1.1`通过`Cache-Control`完成，当`Cache-Control`为`max-age=XXX`时，客户端会计算这个时间加上第一次资源请求的时间是否超时，没超时就直接命中缓存。

协商缓存，由服务器根据`request`的`If-Modified-Since`(客户端根据服务端的`Last-Modified`产生)和`If-None-Match`(客户端根据服务端的`ETag`产生)自己判断是否让客户端使用缓存（返回304），或直接返回资源（返回200）.

## 2. 传输层

### 2.1 TCP

**TCP建立的完整过程**

假设A与B之间建立`TCP`连接，A为主动方，主动向B发起连接。

连接建立：

A（`CLOSED` -> `SYN_SEND`）发出`SYN`、`SEQ`给B   
B（`LISTEN` -> `SYN_RCVD`）接收到SYN后，发送`SYN`、`ACK`、`SEQ`给A   
A（`SYN_SEND` -> `ESTABLISHED`）接收到`SYN`后，发送`ACK`、`SEQ`给B   
B（`SYN_RCVD` -> `ESTABLISHED`）接收到`ACK`后，连接建立完成   

A状态变化：`CLOSED` -> `SYN_SEND` -> `ESTABLISHED`   
B状态变化：`CLOSED` -> `SYN_RCVD` -> `ESTABLISHED`

特殊情况：连接建立的过程中，A发送完`SYN`后，进入`SYN_SEND`的状态，B有可能在接收`SYN`之前，也想主动建立连接而发送`SYN`给A，B也进入`SYN_SEND`状态，此后的状态转换为A和B在收到`SYN`后都由`SYN_SEND`状态转换为`SYN_RCVD`状态，并发送相应信息，然后正常建立连接。

连接断开：

A（`ESTABLISHED` -> `FIN_WAIT_1`）A发送`FIN`、`SEQ`给B   
B（`ESTABLISHED` -> `CLOSE_WAIT`）B接收到`FIN`后，很可能手头还有任务，所以先进入`CLOSE_WAIT`状态，同时发送`ACK`、`SEQ`给B   
A（`FIN_WAIT_1` -> `FIN_WAIT_2`）A收到`ACK`   
B（`CLOSE_WAIT` -> `LAST_ACK`）B手头任务完成后，发送`FIN`、`SEQ`给A   
A（`FIN_WAIT_2` -> `TIME_WAIT`）A接收到`FIN`后，发送`ACK`、`SEQ`给B，A不会立即`CLOSED`因为B收到最后这条消息需要时间，因要保证它们同时关闭   
B（`LAST_WAIT` -> `CLOSED`）B收到`ACK`，进入`CLOSED`状态   
A（`TIME_WAIT` -> `CLOSED`）A等待一段时间，确认B不会再发信息后，进入`CLOSED`状态。连接断开完成。   

A状态变化：`ESTABLISHED` -> `FIN_WAIT_1` -> `FIN_WAIT_2` - > `TIME_WAIT` -> `CLOSED`   
B状态变化：`ESTABLISHED` -> `CLOSE_WAIT` -> `LAST_ACK` -> `CLOSED`

特殊情况，A和B同时发出FIN信号，即A和B可能在FIN_WAIT_1状态收到FIN，这时直接进入CLOSED状态关闭连接就可以了。

**滑动窗口**

滑动窗口协议是接收方控制流量额一种措施，主要防止发送方发送的数据太多而自己接收不过来。具体是接收方每次回复确认报文时，除了确认号外还会带上接收串口大小，当接收方接收到此报文时就可以直到最多可以发送多少报文，比如接收到6大小的接收窗口，而已经发送的报文还有2个还没确认，那么此时最多只能发送6-2个报文。

**计时器**

TCP有四种计时器：重传计时器，

重传计时器：每当发送一个报文启动一个重传计时器，收到确认报文时取消，当计时器到时后仍未收到确认报文，便启动重传，并重新计时。   
坚持计时器：每当发送方收到一个零窗口通告后启动，计时结束后重新询问接收方的接收窗口大小。为了避免接收方在之后有了接收报文能力而发送一个非零窗口通告给发送方，不幸的是该报文丢失了，若没有坚持计时器，发送方只能“傻傻”的等。   
保活计时器：连接空闲时，每隔两小时发送一个探测报文探测对方是否仍旧存活，存活则重新计时，否则关闭连接，释放资源。
2MSL计时器：主动释放连接的一方TIME_WAIT阶段启用。确保FIN的确认报文送达对方，否则当对方没接受到确认报文时会重新发送FIN报文，而此时本方已关闭，TCP会回应一个RST报文，那么对方会认为有错误发生。

**拥塞控制**

拥塞控制方法有：慢开始，拥塞避免，快重传，快恢复。

**慢开始**是指TCP在最开始传输报文时，将拥塞窗口设置为最小值一个MSS（最大报文段），当发出的报文全部接收成功后，雍塞窗口加倍   
**拥塞避免**是指当拥塞窗口达到慢开始门限，每次发出报文全部接收成功，拥塞窗口线性加一
**快重传**要求接收方每收到一个失序报文，需要立即发送出失序报文之前一个报文的重复确认，当发送方收到三个重复确认报文后应当立即重传而不必等到重传计时器生效。
**快恢复**：由于发送方认为现在网络很可能没有发生拥塞，因此不执行慢开始算法，而是在快重传发生时，将慢开始门限设为快重传发生时拥塞窗口的一半，并将拥塞窗口设置为慢开始门限开始拥塞避免算法。新的`TCP Reno`开始采用快恢复算法，快重传之后的采用慢开始算法已基本废弃。慢开始算法只在TCP建立时和网络出现超时时才启用。

接收方也会根据自己的接收能力将接口窗口写在字段中（也就是滑动窗口协议），发送方发送的发送窗口取接收窗口和拥塞窗口中的较小值。

**流量控制**

滑动窗口机制来控制流量。

### 2.2 UDP

### 2.3 TCP与UDP区别

1. TCP提供面向连接的传输，通信前要先建立连接（三次握手机制）；UDP提供无连接的传输，通信前不需要建立连接。
2. TCP提供可靠的传输（有序，无差错，不丢失，不重复）；UDP提供不可靠的传输。
3. TCP面向字节流的传输，因此它能将信息分割成组，并在接收端将其重组；UDP是面向数据报的传输，没有分组开销。
4. TCP提供拥塞控制和流量控制机制；UDP不提供拥塞控制和流量控制机制。

**使用TCP或UDP典型协议**

* TCP一般用在面向连接的服务，这些服务需要高度的可靠性，如：   

  **Telnet**协议，**FTP**协议，**SMTP**协议，**POP3**协议，**HTTP**协议

* UDP一般用在面向查询的服务，如：  

  **DHCP**协议，**DNS**协议(发送和接收域名数据库时会用到TCP)，**TFTP**协议，**SNMP**协议（网络管理协议），**NTP**协议(网络时间协议)，**BOOTP**协议

## 2. 网络层

IP，ICMP，RIP，ARP，RARP
