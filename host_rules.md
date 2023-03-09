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
--host-rules="MAP github.com octocaptcha.com:443, MAP gist.github.com octocaptcha.com:443" --host-resolver-rules="MAP octocaptcha.com 20.205.243.166"
```

- duckduckgo
```
--host-rules="MAP duckduckgo.com duck.com:443, MAP *.duckduckgo.com duck.com:443" --host-resolver-rules="MAP duck.com 20.43.161.105"
```

- twitter
```
--host-rules="MAP twitter.com tweetdeck.com:443, MAP *.twitter.com tweetdeck.com:443, MAP abs.twimg.com tweetdeck.com:443, MAP pbs.twimg.com tweetdeck.com:443, MAP abs-0.twimg.com twimg.com:443, MAP video.twimg.com test.twimg.com:443" --host-resolver-rules="MAP tweetdeck.com 104.244.45.4, MAP twimg.com 146.75.116.159, MAP test.twimg.com 192.229.220.133"
```

