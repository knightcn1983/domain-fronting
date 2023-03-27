## 支持的网站列表
（本文档由脚本生成）

相同参数的内容合并在一起，可以让多个网站使用域前置。

如果部署并设置了 cloudflare workers，proxy hosts 可通过其转发。

### 维基百科

- domain fronting:
```
upload.wikimedia.org
*.wikipedia.org
wikimedia.org
*.wikimedia.org
```
```
--host-rules="MAP upload.wikimedia.org upload.wikimedia.org:443, MAP *.wikipedia.org wikivoyage.org:443, MAP wikimedia.org wikivoyage.org:443, MAP *.wikimedia.org wikivoyage.org:443" --host-resolver-rules="MAP upload.wikimedia.org 103.102.166.240, MAP wikivoyage.org 208.80.153.224"
```

### google

- domain fronting:
```
google.com
youtube.com
*.google.com
*.gstatic.com
*.googleapis.com
*.googleusercontent.com
*.ytimg.com
*.youtube.com
*.ggpht.com
```
```
--host-rules="MAP google.com www.gstatic.cn:443, MAP youtube.com www.gstatic.cn:443, MAP *.google.com www.gstatic.cn:443, MAP *.gstatic.com www.gstatic.cn:443, MAP *.googleapis.com www.gstatic.cn:443, MAP *.googleusercontent.com www.gstatic.cn:443, MAP *.ytimg.com www.gstatic.cn:443, MAP *.youtube.com www.gstatic.cn:443, MAP *.ggpht.com www.gstatic.cn:443" --host-resolver-rules="MAP www.gstatic.cn 106.75.251.36"
```


- proxy hosts:
```
googlevideo.com
```

### github

- domain fronting:
```
github.com
gist.github.com
github.githubassets.com
*.githubusercontent.com
```
```
--host-rules="MAP github.com octocaptcha.com:443, MAP gist.github.com octocaptcha.com:443, MAP github.githubassets.com g.yelp.com:443, MAP *.githubusercontent.com g.yelp.com:443" --host-resolver-rules="MAP octocaptcha.com 20.27.177.113, MAP g.yelp.com 151.101.40.116"
```

### duckduckgo

- domain fronting:
```
duckduckgo.com
*.duckduckgo.com
```
```
--host-rules="MAP duckduckgo.com duck.com:443, MAP *.duckduckgo.com duck.com:443" --host-resolver-rules="MAP duck.com 20.43.161.105"
```

### twitter

- domain fronting:
```
twitter.com
*.twitter.com
*.twimg.com
```
```
--host-rules="MAP twitter.com tweetdeck.com:443, MAP *.twitter.com tweetdeck.com:443, MAP *.twimg.com t.yelp.com:443" --host-resolver-rules="MAP tweetdeck.com 104.244.45.4, MAP t.yelp.com 151.101.40.116"
```

### pixiv

- domain fronting:
```
pixiv.net
*.pixiv.net
*.pximg.net
```
```
--host-rules="MAP pixiv.net fanbox.cc:443, MAP *.pixiv.net fanbox.cc:443, MAP *.pximg.net pximg.net:443" --host-resolver-rules="MAP fanbox.cc 210.140.131.221, MAP pximg.net 210.140.139.136"
```

### quora

- domain fronting:
```
quora.com
*.quora.com
```
```
--host-rules="MAP quora.com qr.ae:443, MAP *.quora.com qr.ae:443" --host-resolver-rules="MAP qr.ae 107.20.115.65"
```

### flickr

- domain fronting:
```
identity.flickr.com
flickr.com
*.flickr.com
```
```
--host-rules="MAP identity.flickr.com flic.kr:443, MAP flickr.com combo.staticflickr.com:443, MAP *.flickr.com combo.staticflickr.com:443" --host-resolver-rules="MAP flic.kr 34.231.89.51, MAP combo.staticflickr.com 13.35.66.99"
```

### onedrive

- domain fronting:
```
onedrive.live.com
skyapi.onedrive.live.com
```
```
--host-rules="MAP onedrive.live.com od0.live.com:443, MAP skyapi.onedrive.live.com od0.docs.live.net:443" --host-resolver-rules="MAP od0.live.com 13.107.42.13, MAP od0.docs.live.net 13.105.28.18"
```

### reddit

- domain fronting:
```
reddit.com
*.reddit.com
*.redd.it
*.redditmedia.com
*.redditstatic.com
```
```
--host-rules="MAP reddit.com r.yelp.com:443, MAP *.reddit.com r.yelp.com:443, MAP *.redd.it r.yelp.com:443, MAP *.redditmedia.com r.yelp.com:443, MAP *.redditstatic.com r.yelp.com:443" --host-resolver-rules="MAP r.yelp.com 151.101.40.116"
```

### instagram

- domain fronting:
```
instagram.com
*.instagram.com
*.cdninstagram.com
```
```
--host-rules="MAP instagram.com igsonar.com:443, MAP *.instagram.com igsonar.com:443, MAP *.cdninstagram.com igsonar.com:443" --host-resolver-rules="MAP igsonar.com 31.13.66.167"
```

