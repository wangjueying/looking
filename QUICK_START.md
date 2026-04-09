# 物品追踪器快速开始

这份文档面向最终用户，默认使用 Android APK。

## 1. 下载应用

发布版本后，直接从 GitHub Releases 下载 APK：

- [https://github.com/wangjueying/looking/releases](https://github.com/wangjueying/looking/releases)

如果手机提示风险，请在系统设置中允许安装未知来源应用。

## 2. 准备 API Key

应用不会内置 AI 服务密钥，首次使用前需要自行准备 DashScope API Key：

1. 打开 [https://dashscope.console.aliyun.com/](https://dashscope.console.aliyun.com/)
2. 创建 API Key
3. 复制并保存这个 Key

## 3. 首次打开应用

1. 进入应用设置页
2. 在 `API Key` 输入框中粘贴你的 Key
3. 保存后返回首页

## 4. 录入物品

你可以选择以下任一方式录入：

- `拍照识别`
- `相册图片`
- `相册视频`

识别完成后，结果会自动保存到本地数据库。

## 5. 查找物品

1. 进入 `搜索物品`
2. 输入关键词
3. 点击搜索结果进入详情
4. 查看原始图片或视频，以及位置说明

## 6. 管理清单

1. 进入 `物品清单`
2. 浏览所有当前显示的条目
3. 将不想继续显示的条目移出清单
4. 即使移出清单，仍然可以在搜索页重新找回并恢复

## 常见问题

### 为什么不能直接使用？

因为识别能力依赖 DashScope API，每个用户都需要配置自己的 API Key。

### 数据保存在哪里？

识别结果默认保存在本地 SQLite 数据库，便于离线查看历史记录。

### 视频识别适合什么场景？

适合用短视频快速扫过一片区域，帮助回忆物品大概放在什么位置。

## 更多说明

- 详细使用说明见 `USER_GUIDE.md`
- 开发说明见 `README.md`