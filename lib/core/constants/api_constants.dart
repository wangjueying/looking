class ApiConstants {
  static const String baseUrl = 'https://dashscope.aliyuncs.com/api/v1/services/aigc/multimodal-generation/generation';

  static const String model = 'qwen-vl-max';

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
