# 物品追踪器

AI 驱动的物品记录应用，帮助用户用图片或视频记录物品与存放位置，并在之后通过搜索快速找回。

## 当前能力

- 支持拍照识别、相册图片识别、相册视频识别
- 识别结果会保存到本地 SQLite 数据库
- 支持关键词搜索，并可从搜索结果进入详情查看原始图片或视频
- 支持将条目从清单移出，同时保留搜索可找回能力
- 支持从搜索结果或详情页恢复到物品清单

## 面向用户的使用方式

### Android 用户

维护者发布版本后，可直接在 GitHub Releases 页面下载 APK：

- Releases: [https://github.com/wangjueying/looking/releases](https://github.com/wangjueying/looking/releases)
- 首次使用需要在应用设置页配置自己的 DashScope API Key

安装后建议按这个顺序使用：

1. 打开应用并进入设置页
2. 填入自己的 DashScope API Key
3. 通过拍照、相册图片或相册视频录入物品
4. 在搜索页输入关键词查找物品
5. 点进详情查看原始媒体和位置说明

## 本地开发

### 前置条件

- Flutter SDK 3.24+
- Dart SDK 3.4+
- Android Studio 或 VS Code
- 可用的 DashScope API Key

### 运行项目

```bash
flutter pub get
flutter run
```

### 执行检查

```bash
flutter analyze
flutter test
```

### 构建 APK

```bash
flutter build apk --release
```

构建产物位置：

`build/app/outputs/flutter-apk/app-release.apk`

## API Key

应用不会内置 API Key。每个用户都需要自行到 DashScope 控制台创建并配置：

1. 打开 [https://dashscope.console.aliyun.com/](https://dashscope.console.aliyun.com/)
2. 创建 API Key
3. 在应用设置页中粘贴保存

## 项目结构

当前仓库使用根目录 Flutter 工程，默认入口和主要业务代码都位于 `lib/`。

```text
android/                Android 工程
ios/                    iOS 工程
lib/                    主要业务代码与默认入口
test/                   测试代码
```

## 自动化构建

- 推送到 `main` 或 `develop` 时会执行分析、测试并产出调试 APK 制品
- 推送 `v*` 标签时会构建 release APK，并附加到 GitHub Release

## 已知限制

- 当前重点支持 Android 使用场景
- 首次使用必须自行提供 DashScope API Key
- GitHub 直发 APK 适合直接下载安装，不等同于应用商店正式发布

## 常见问题

### 数据会上传到服务器吗？

- 原始图片或视频只会在识别时发送到 DashScope API
- 识别结果默认保存在本地 SQLite
- 不会额外上传到项目自建服务器

### 识别不准确怎么办？

- 尽量保证光线充足、主体清晰
- 可在详情页手动补充或修正名称、描述和位置
- 视频识别建议选择较短、画面稳定的片段

## 许可证

MIT License
