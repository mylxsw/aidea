# AIdea - AI 聊天、协作、图像生成

[![FOSSA Status](https://app.fossa.com/api/projects/custom%2B39727%2Fgithub.com%2Fmylxsw%2Faidea.svg?type=shield&issueType=license)](https://app.fossa.com/projects/custom%2B39727%2Fgithub.com%2Fmylxsw%2Faidea?ref=badge_shield)
![GitHub release (by tag)](https://img.shields.io/github/downloads/mylxsw/aidea/1.0.3/total)
![GitHub](https://img.shields.io/github/license/mylxsw/aidea)


一款集成了主流大语言模型以及绘图模型的 APP， 采用 Flutter 开发，代码完全开源，支持以下功能：

- 支持 GPT-3.5/4 问答聊天
- 支持国产模型：通义千问，文心一言
- 支持文生图、图生图、超分辨率、黑白图片上色等功能，集成 Stable Diffusion 模型，支持 SDXL 1.0

开源代码：

- 客户端：https://github.com/mylxsw/aidea
- 服务端：https://github.com/mylxsw/aidea-server （即将开放）

微信技术交流群：

<img src="https://github.com/mylxsw/aidea/assets/2330911/36087479-36bb-4871-9e34-3bdf752a1188" width="400" />

> 微信群满了加不进去的话，可以添加微信号 `x-prometheus` 为好友，拉你进群。
> 
> <img src="https://github.com/mylxsw/aidea/assets/2330911/655601c1-9371-4460-9657-c58521260336" width="400"/>

电报群：[点此加入](https://t.me/aideachat)

## 下载安装地址

Android/IOS APP：https://aidea.aicode.cc/

> IOS 国区目前不可用，除此之外所有区域都可以下载。
>
> 2023 年 9 月 4 日发现国区被下架后，非国区 IOS 版本可能无法完成应用内购（提示“你的购买无法完成”，但是也有人能够成功支付），暂时无法充值，最新进展在这里 [issue#16](https://github.com/mylxsw/aidea/issues/16)。

Mac 桌面端：https://github.com/mylxsw/aidea/releases

Web 端：https://web.aicode.cc/

## 福利

目前我的 OpenAI 账户还有大约 4900+ 美金的额度，为了感谢各位的关注，在满足以下几个条件之前（任意），GPT-4 使用价格调整为 10 个智慧果每 1K Token （约等于 1 毛钱，OpenAI 官方价格为输入 2 毛 1 ，输出 4 毛 2 ）：

- 截止至 2023 年 11 月 1 日
- 4900 美金额度消耗完

> 本来想免费的，但是仔细想了想不敢这么干，万一有人滥用那不是全浪费掉了。

## APP 截图


![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-32-34.png-thumb)  | ![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-32-42.png-thumb)
:-------------------------:|:-------------------------:
![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-32-53.png-thumb)  | ![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-33-44.png-thumb) 
![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-34-14.png-thumb)  | ![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-34-28.png-thumb) 
![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-34-42.png-thumb)  | ![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-35-01.png-thumb) 
![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-35-33.png-thumb)  | ![images](https://ssl.aicode.cc/ai-server/article/Xnip2023-08-30_11-35-52.png-thumb)

## 如果对你有帮助，请我喝杯酒吧

微信  | 支付宝
:-------------------------:|:-------------------------:
![image](https://github.com/mylxsw/aidea/assets/2330911/46e2242b-17bc-41ff-bebe-b5cc466b7f17) | ![image](https://github.com/mylxsw/aidea/assets/2330911/f3c85d4a-bea8-4a76-b582-c673613f76cb)


## 常见问题

### 1. Mac 桌面端应用无法打开，报错如下

<img width="300" src="https://user-images.githubusercontent.com/15153075/264509300-426d70bd-fd1b-4078-9eb9-5588a917b023.png">

临时解决方案，命令行执行

```bash
sudo codesign -f -s - /Applications/AIdea.app
```

<img width="1125" alt="image" src="https://github.com/mylxsw/aidea/assets/2330911/5ef3fbe1-6cb3-4a64-9c17-82dd8c864ac7">

### 2. Web 端使用 Nginx 部署后，`canvaskit.wasm` 文件响应的 `Content-Type`  是 `application/octet-stream`，而不是 `application/wasm` 

在 Nginx 配置文件 `/etc/nginx/mime.types` 中，增加 wasm 支持

```nginx
application/wasm wasm;
```

## Star History

<a href="https://star-history.com/#mylxsw/aidea&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=mylxsw/aidea&type=Date&theme=dark" />
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=mylxsw/aidea&type=Date" />
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=mylxsw/aidea&type=Date" />
  </picture>
</a>

## License

MIT

Copyright (c) 2023, mylxsw

[![FOSSA Status](https://app.fossa.com/api/projects/custom%2B39727%2Fgithub.com%2Fmylxsw%2Faidea.svg?type=large)](https://app.fossa.com/projects/custom%2B39727%2Fgithub.com%2Fmylxsw%2Faidea?ref=badge_large)
