class ApiConstants {
  // API基础URL
  static const String aiApiBaseUrl = 'https://dashscope.aliyuncs.com';

  // 通义千问API端点
  static const String multimodalGeneration =
      '/api/v1/services/aigc/multimodal-generation/generation';

  // 请求头
  static const String contentType = 'application/json';
  static const String authorizationHeader = 'Authorization';

  // 超时配置
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 30);

  // 重试配置
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
