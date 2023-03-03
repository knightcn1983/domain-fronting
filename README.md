无需代理服务器，通过域前置(domain fronting)访问某些网站，比如维基百科或Google翻译。有关域前置的相关说明，请到[维基百科页面][df]查看。
若一个网站被封，一般并不是它的所有域名都被封，就因为这样我们得以使用域前置技术绕过封锁。

本repo提供被封网站的某个没有被封的域名和IP。

有两种方法可以使用域前置：

1. 使用chromium内核的浏览器，比如Google浏览器，微软的edge，brave等，缺点是只能在浏览器上使用
2. 借助[mitmproxy][mitm]和[域前置脚本][df-py]


### 第一种方法
这方法比较简单，只需要在运行浏览器时加入两个参数。
```
--host-rules="<rules>" --host-resolver-rules="<rules>"
```
[host_rules.md][rules] 有 `<rules>` 的内容。


[df]: https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%89%8D%E7%BD%AE
[mitm]: https://github.com/mitmproxy/mitmproxy
[df-py]: https://github.com/rabbit2123/domain-fronting/blob/main/domain_fronting.py
[wiki]: https://zh.wikipedia.org/
[rules]: https://github.com/rabbit2123/domain-fronting/blob/main/host_rules.md
[source]: https://github.com/rabbit2123/domain-fronting/blob/main/hosts.source.txt

------



### 支持域前置的网站列表
请看[host_rules.md][rules]。


### contribute
欢迎加入其他支持域前置的网站。只要修改[hosts.source.txt][source]即可。
此文件的格式：
```
# 以#开头的是注释，以及空行会被忽略
# 以=== 开头为网站名称
# 每行包含有四个字段，sni域名是没被封的可用于sni连接的域名
sni域名 IP 端口 被封的域名...
```
比如
```
=== google
www.gstatic.cn 106.75.251.36 443 *.google.com *.gstatic.com
```
每行的后面可以有多个域名。











