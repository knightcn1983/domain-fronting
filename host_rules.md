### 支持的网站列表
（本文档由脚本生成）

相同参数的内容合并在一起，可以让多个网站使用域前置。

- 维基百科
```
--host-rules="MAP upload.wikimedia.org upload.wikimedia.org:443, MAP *.wikipedia.org wikivoyage.org:443, MAP wikimedia.org wikivoyage.org:443, MAP *.wikimedia.org wikivoyage.org:443" --host-resolver-rules="MAP upload.wikimedia.org 103.102.166.240, MAP wikivoyage.org 208.80.153.224"
```

- google
```
--host-rules="MAP *.google.com www.gstatic.cn:443, MAP *.gstatic.com www.gstatic.cn:443, MAP *.googleapis.com www.gstatic.cn:443, MAP *.googleusercontent.com www.gstatic.cn:443, MAP *.ytimg.com www.gstatic.cn:443, MAP *.youtube.com www.gstatic.cn:443, MAP *.ggpht.com www.gstatic.cn:443" --host-resolver-rules="MAP www.gstatic.cn 106.75.251.36"
```

- github
```
--host-rules="MAP github.com octocaptcha.com:443" --host-resolver-rules="MAP octocaptcha.com 20.205.243.166"
```

