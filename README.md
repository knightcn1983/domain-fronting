通过域前置访问某些网站，比如维基百科或Google翻译。有关域前置的相关说明，请到[维基百科页面][df]查看。
若一个网站被封，一般并不是它的所有域名都被封，就因为这样我们得以使用域前置技术绕过封锁。
有两种方法可以使用域前置：

1. 使用chromium内核的浏览器，比如Google浏览器，微软的edge，brave等
2. 借助[mitmproxy][mitm]和[域前置脚本][df-py]

第一种方法比较简单，只需要在运行浏览器时加入两个参数。本repo提供被封网站的某个没有被封的域名和IP。
以维基百科为例，虽然主域名 `wikipedia.org` 被封了，但是 `hello.wikivoyage.org` 并没有。
所有运行上述浏览器时加入以下两个参数就可以访问[维基百科][wiki]了。
```
--host-rules="MAP *.wikipedia.org hello.wikivoyage.org, MAP commons.wikimedia.org hello.wikivoyage.org" --host-resolver-rules="MAP upload.wikimedia.org 103.102.166.240, MAP hello.wikivoyage.org 208.80.153.224"
```



[df]: https://zh.wikipedia.org/wiki/%E5%9F%9F%E5%89%8D%E7%BD%AE
[mitm]: https://github.com/mitmproxy/mitmproxy
[df-py]: https://github.com/mitmproxy/mitmproxy/blob/main/examples/contrib/domain_fronting.py
[wiki]: https://zh.wikipedia.org/
