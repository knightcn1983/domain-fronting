新建一个 Worker，然后使用快速编辑，将 `index.js` 内容粘贴部署。

### 如何工作
这个 worker 提供两个 API 接口，可以转发其他 http 请求。
分别是 `/http/` 及 `/https/` 对应于 `HTTP` 和 `HTTPS` 协议。

比如要请求 
```
https://google.com/
```
把链接改成以下则可。
```
https://yourworker-name.workers.dev/https/google.com/
```

或者 
```
http://google.com/
```

```
https://yourworker-name.workers.dev/http/google.com/
```

但 wokers.dev 被拦截，最好设置自定义域名才行。
