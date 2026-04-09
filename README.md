# 物品追踪器 (Item Tracker)

AI驱动的物品位置追踪应用，帮你快速找到存放的物品。

## 功能特性

- 🤖 **AI物品识别** - 使用通义千问API自动识别图片中的物品
- 📸 **相机拍照** - 直接拍照记录物品位置
- 🖼️ **相册选择** - 从相册选择图片进行识别
- 🔍 **全文搜索** - 快速搜索已识别的物品
- 📋 **物品清单** - 查看所有已识别物品
- 💾 **本地存储** - SQLite数据库，保护隐私

## 技术栈

- **Flutter 3.24.0** - 跨平台移动应用框架
- **Dart** - 编程语言
- **Riverpod** - 状态管理
- **GoRouter** - 路由管理
- **SQLite** - 本地数据库
- **Dio** - 网络请求
- **通义千问 qwen-vl-max** - AI视觉模型

## 快速开始

### 前置要求

- Flutter SDK 3.24.0+
- Dart 3.4+
- Android Studio / VS Code
- 通义千问 API Key

### 获取API Key

1. 访问 [通义千问控制台](https://dashscope.console.aliyun.com/)
2. 创建API Key
3. 保存API Key（应用启动时会要求输入）

### 安装和运行

1. 克隆仓库
```bash
git clone https://github.com/wangjueying/looking.git
cd looking_2
```

2. 安装依赖
```bash
flutter pub get
```

3. 运行代码生成
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. 运行应用
```bash
flutter run
```

### 构建APK

使用GitHub Actions自动构建（推荐）：
- 推送代码到GitHub
- 在Actions标签页查看构建状态
- 构建完成后下载APK

或本地构建：
```bash
flutter build apk --release
```

APK位置: `build/app/outputs/flutter-apk/app-release.apk`

## 使用说明

1. **首次使用** - 启动应用后输入通义千问API Key
2. **拍照识别** - 点击"拍照识别"按钮，对准物品拍照
3. **相册选择** - 点击"相册选择"从相册选择图片
4. **查看结果** - AI自动识别物品信息并保存
5. **搜索物品** - 在搜索页面输入关键词查找物品
6. **查看清单** - 在清单页面浏览所有物品记录

## 项目结构

```
lib/
├── core/                          # 核心功能
│   ├── constants/                 # 常量
│   ├── errors/                    # 错误处理
│   ├── network/                   # 网络客户端
│   └── utils/                     # 工具类
├── features/                      # 功能模块
│   ├── item/                      # 物品功能
│   │   ├── data/                  # 数据层
│   │   ├── domain/                # 领域层
│   │   └── presentation/          # 表现层
│   └── settings/                  # 设置功能
└── main.dart                      # 应用入口
```

## GitHub Actions

项目配置了GitHub Actions自动构建APK：

- **触发条件**: 推送到main或develop分支
- **构建类型**: Debug和Release
- **输出**: 可下载的APK文件
- **保留时间**: Debug 30天，Release 90天

## 常见问题

### API Key在哪获取？
访问 https://dashscope.console.aliyun.com/ 创建API Key

### 识别不准确怎么办？
- 确保图片清晰，光线充足
- 物品特征明显，避免遮挡
- 可以手动编辑物品信息

### 数据会上传到服务器吗？
- 图片仅在AI识别时上传到通义千问API
- 识别后的数据存储在本地SQLite数据库
- 不会上传到其他服务器

## 开发路线图

- [ ] 用户系统和云同步
- [ ] 多语言支持
- [ ] 物品分类和标签
- [ ] 批量识别功能
- [ ] 数据导出功能
- [ ] AR导航功能

## 许可证

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 联系方式

- GitHub: https://github.com/wangjueying/looking
- Issues: https://github.com/wangjueying/looking/issues
