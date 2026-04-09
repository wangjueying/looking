import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: ApiConstants.headers,
        connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      ),
    );
  }

  void setApiKey(String apiKey) {
    _dio.options.headers['Authorization'] = 'Bearer $apiKey';
  }

  bool hasDefaultHeaders() {
    return _dio.options.headers.containsKey('Authorization');
  }

  Future<Map<String, dynamic>> identifyItem(String base64Image) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'model': ApiConstants.model,
          'input': {
            'messages': [
              {
                'role': 'system',
                'content': [
                  {
                    'text': '''你是一个专业的物品识别助手。请仔细观察图片，识别其中的物品并提供以下信息：
1. 物品名称（简短，2-5个字）
2. 详细描述（外观、颜色、材质等特征）
3. 存放位置（根据图片背景推断位置，如"卧室桌面"、"客厅沙发"等）
4. 置信度（0-1之间的数字，表示识别的准确性）

请以JSON格式返回，格式如下：
{
  "name": "物品名称",
  "description": "详细描述",
  "location": "存放位置",
  "confidence": 0.95
}'''
                  }
                ]
              },
              {
                'role': 'user',
                'content': [
                  {
                    'image': base64Image
                  },
                  {
                    'text': '请识别图片中的物品'
                  }
                ]
              }
            ]
          }
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(
          'API request failed with status ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException('Connection error: ${e.message}');
      } else if (e.response != null) {
        throw ServerException(
          'API error: ${e.response?.statusMessage}',
          e.response?.statusCode,
        );
      } else {
        throw NetworkException('Network error: ${e.message}');
      }
    }
  }

  void dispose() {
    _dio.close(force: true);
  }
}
