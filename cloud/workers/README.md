### 部署 Workers
---
新建一个 Worker，使用快速编辑，将 `index.js` 内容粘贴上去。

### 部署 Pages
---
在 cloudflare pages 上新建一个项目。

下载 `workers` 目录到本地，重命名 `index.js` 为 `_worker.js`，再上传目录。


### 如何工作
---
这个 worker 提供两个 API 接口转发 http 请求。
分别是 `/http/` 及 `/https/` 对应于 `HTTP` 和 `HTTPS` 协议。

```
https://google.com/
https://yourworker-name.workers.dev/https/google.com/
```

```
http://google.com/
https://yourworker-name.workers.dev/http/google.com/
```

### 自定义域名
---
需要将域名托管到 Cloudflare 才能设置 Workers 的自定义域名，但 Pages 只用 CNAME 指向。
