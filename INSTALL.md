# 物品追踪器 - 安装说明

## 📱 APK 安装指南

### 方法1：直接安装APK（推荐）

APK文件位置：
```
build/app/outputs/flutter-apk/app-debug.apk
```

**文件大小**: 147MB

#### 安装步骤：

1. **将APK传输到手机**
   - 使用数据线连接手机和电脑
   - 复制 `app-debug.apk` 到手机

2. **在手机上安装**
   - 在文件管理器中找到APK文件
   - 点击安装
   - 允许安装来自未知来源的应用（如果提示）

3. **授予权限**
   - 相册权限（必需）
   - 存储权限（必需）

4. **配置API Key**
   - 启动应用
   - 输入通义千问API Key
   - 获取地址：https://dashscope.console.aliyun.com/

### 方法2：使用adb安装（开发者）

如果已安装Android SDK Platform Tools：

```bash
# 1. 连接手机到电脑，启用USB调试
adb devices

# 2. 安装APK
adb install build/app/outputs/flutter-apk/app-debug.apk

# 3. 启动应用
adb shell am start -n com.itemtracker.looking_2/.MainActivity
```

### 方法3：GitHub Actions自动构建（推荐用于生产）

推送到GitHub后会自动构建APK：

1. 推送代码到GitHub
2. 在Actions标签页查看构建状态
3. 下载生成的APK文件

## 🔧 系统要求

- **Android版本**: 5.0 (API 21) 或更高
- **存储空间**: 至少200MB可用空间
- **网络**: WiFi或移动网络（用于AI识别）

## 📖 使用说明

1. **首次使用**
   - 启动应用
   - 输入通义千问API Key
   - API Key会安全存储在设备上

2. **添加物品**
   - 点击"从相册选择图片识别"
   - 选择物品图片
   - 等待AI识别（约3-5秒）
   - 查看识别结果

3. **搜索物品**
   - 切换到"搜索"标签
   - 输入物品名称、描述或位置
   - 查看搜索结果

4. **查看清单**
   - 切换到"清单"标签
   - 浏览所有物品记录
   - 点击物品查看详情

## 🐛 故障排除

### 安装失败
- 检查Android版本是否≥5.0
- 确保允许安装未知来源应用
- 清理手机存储空间

### 识别失败
- 检查网络连接
- 验证API Key是否正确
- 确保API账户有足够余额

### 应用崩溃
- 清除应用数据
- 卸载并重新安装
- 联系开发者

## 📞 获取帮助

- GitHub Issues: https://github.com/wangjueying/looking/issues
- 完整文档: 查看 README.md

---

**享受使用物品追踪器！** 🎉
