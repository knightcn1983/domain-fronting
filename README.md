无需代理服务器，通过域前置(domain fronting)访问某些网站，比如维基百科或 Google 翻译。有关域前置的相关说明，请到[维基百科页面][wiki-df]查看。
若一个网站被封，一般并不是它的所有域名都被封，就因为这样我们得以使用域前置技术绕过封锁。

本 repo 提供被封网站的某个没有被封的域名和 IP。

## 支持域前置的网站列表
---
请看 [host_rules.md][rules]。要支持其他网站请提交 issue。


## 怎么使用
---
有两种方法可以使用域前置：

1. 使用 chromium 内核的浏览器，比如 Google 浏览器，微软的 edge，brave等，缺点是只能在浏览器上使用
2. 借助 [mitmproxy][mitm] 和域前置脚本，支持 http2


### 第一种方法
---
这方法比较简单，只要在启动浏览器时加入两个参数：
```
"浏览器可执行文件" --host-rules="<rules>" --host-resolver-rules="<rules>"
```
在 `powershell` 上运行要在命令前加上 `& `。

浏览器的执行文件路径可在浏览器打开 `chrome://version` 找到。

微软的 edge 还需到浏览器的`设置->系统与性能`把`启动增强`关闭，否则参数不生效。

参数内容请看[host_rules.md][rules]或者[df.txt][df-all]([mirror][df-link])。


### 第二种方法
---
按照以下步骤操作完成后，http 代理监听在 127.0.0.1:8080，加参数 `-p PORT` 可修改端口。 

1. 安装 [mitmproxy][mitm-dl]
2. 下载相应文件
    - 电信网络：`df-dianxin.py` `hosts-dianxin.txt`
    - 其他网络：`df-other.py` `hosts-other.txt`
3. 复制 `hosts文件` 内容添加到系统 `hosts` 文件
4. 打开命令行并切换到 `py文件` 所在目录，然后运行
```
mitmdump.exe -s ./py文件
```
5. 配置浏览器或系统使用 http 代理
6. 在浏览器打开 http://mitm.it 按照提示安装 CA 证书，否则会报证书错误。


#### Cloudflare Workers/Pages(可选)
---
有些网站域名不可用域前置，但可用 Workers/Pages 转发，请先[部署][workers]，
然后在 `py文件` 设置域名。
```
# cloudflare workers/pages 域名和端口
SERVER = "your-domain.com"
```

如果网站既能用域前置又能通过Workers/Pages转发，优先使用域前置。


## Contribute
---
欢迎加入其他支持域前置的网站，请看[hosts.source.txt][source]。


## Credit
---
`_df.py` 由 mitmproxy 的 [domain_fronting.py][mitm-df] 修改而来。



[wiki-df]: https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%89%8D%E7%BD%AE
[mitm]: https://github.com/mitmproxy/mitmproxy
[mitm-dl]: https://mitmproxy.org/
[rules]: https://github.com/rabbit2123/domain-fronting/blob/main/host_rules.md
[source]: https://github.com/rabbit2123/domain-fronting/blob/main/hosts.source.txt
[mitm-df]: https://github.com/mitmproxy/mitmproxy/blob/main/examples/contrib/domain_fronting.py
[workers]: https://github.com/rabbit2123/domain-fronting/tree/main/cloud/workers
[df-all]: https://github.com/rabbit2123/domain-fronting/blob/main/df.txt
[df-link]: https://cf.rabbit2123.kozow.com/gh/domain-fronting/main/df.txt
