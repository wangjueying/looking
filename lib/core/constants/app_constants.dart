class AppConstants {
  // 应用信息
  static const String appName = '物品追踪器';
  static const String appVersion = '1.0.0';

  // AI API配置
  static const String aiApiBaseUrl = 'https://dashscope.aliyuncs.com';
  static const String aiModel = 'qwen-vl-max';
  static const int aiMaxTokens = 4000;
  static const double aiTemperature = 0.3;

  // 数据库配置
  static const String databaseName = 'item_tracker.db';
  static const int databaseVersion = 2;

  // 表名
  static const String itemsTable = 'items';

  // 存储路径
  static const String imagesDir = 'item_images';
  static const String videosDir = 'item_videos';

  // 文件大小限制
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const int maxVideoSize = 100 * 1024 * 1024; // 100MB

  // 图片压缩配置
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1920;
  static const int imageQuality = 85;

  // 搜索防抖延迟（毫秒）
  static const int searchDebounceMs = 500;
}
