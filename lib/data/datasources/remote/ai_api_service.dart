import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../../core/constants/api_constants.dart';
import '../../models/analysis_request_model.dart';
import '../../models/analysis_result_model.dart';

class AIApiService {
  final Dio _dio;
  String? _apiKey;

  AIApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.aiApiBaseUrl,
              connectTimeout: ApiConstants.connectionTimeout,
              receiveTimeout: ApiConstants.receiveTimeout,
              sendTimeout: ApiConstants.sendTimeout,
              headers: {'Content-Type': ApiConstants.contentType},
            ),
          );

  // 设置API Key
  void setApiKey(String apiKey) {
    _apiKey = apiKey;
    if (apiKey.isNotEmpty) {
      _dio.options.headers[ApiConstants.authorizationHeader] = 'Bearer $apiKey';
    } else {
      _dio.options.headers.remove(ApiConstants.authorizationHeader);
    }
  }

  // 清除API Key
  void clearApiKey() {
    _apiKey = null;
    _dio.options.headers.remove(ApiConstants.authorizationHeader);
  }

  // 获取API Key
  String? getApiKey() => _apiKey;

  // 检查是否已配置API Key
  bool get isApiKeySet =>
      _apiKey != null && _apiKey!.isNotEmpty && _apiKey!.length > 10;

  // 分析图片
  Future<AnalysisResultModel> analyzeImage(String imagePath) async {
    if (!isApiKeySet) {
      throw Exception('API Key未设置或无效，请先设置通义千问API Key');
    }

    try {
      // 1. 读取并编码图片
      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw Exception('图片文件不存在: $imagePath');
      }

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      // 2. 构建请求
      final request = AnalysisRequestModel.forImageAnalysis(base64Image);

      // 3. 发送API请求
      final response = await _dio.post(
        ApiConstants.multimodalGeneration,
        data: request.toJson(),
      );

      // 4. 解析响应
      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('图片分析失败: $e');
    }
  }

  // 分析视频
  Future<AnalysisResultModel> analyzeVideo(String videoPath) async {
    if (!isApiKeySet) {
      throw Exception('API Key未设置或无效，请先设置通义千问API Key');
    }

    try {
      final videoFile = File(videoPath);
      if (!videoFile.existsSync()) {
        throw Exception('视频文件不存在: $videoPath');
      }

      final videoPayload = await _extractVideoFrames(videoPath);
      final request = AnalysisRequestModel.forVideoAnalysis(
        videoPayload.frames,
        fps: videoPayload.fps,
      );

      final response = await _dio.post(
        ApiConstants.multimodalGeneration,
        data: request.toJson(),
      );

      return _parseResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('视频分析失败: $e');
    }
  }

  Future<_VideoFramePayload> _extractVideoFrames(String videoPath) async {
    final controller = VideoPlayerController.file(File(videoPath));

    try {
      await controller.initialize();

      final duration = controller.value.duration;
      final frameCount = _determineFrameCount(duration);
      final sampleTimes = _buildSampleTimes(duration, frameCount);
      final frames = <String>[];

      for (final timeMs in sampleTimes) {
        final thumbnailBytes = await VideoThumbnail.thumbnailData(
          video: videoPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 640,
          quality: 75,
          timeMs: timeMs,
        );

        if (thumbnailBytes != null && thumbnailBytes.isNotEmpty) {
          frames.add('data:image/jpeg;base64,${base64Encode(thumbnailBytes)}');
        }
      }

      if (frames.isEmpty) {
        throw Exception('无法从视频中提取关键帧');
      }

      while (frames.length < 4) {
        frames.add(frames.last);
      }

      return _VideoFramePayload(
        frames: frames,
        fps: _calculateFps(duration, frames.length),
      );
    } finally {
      await controller.dispose();
    }
  }

  int _determineFrameCount(Duration duration) {
    final seconds = duration.inSeconds;

    if (seconds <= 5) {
      return 4;
    }

    if (seconds <= 15) {
      return 6;
    }

    if (seconds <= 30) {
      return 8;
    }

    return 10;
  }

  List<int> _buildSampleTimes(Duration duration, int frameCount) {
    final totalMs = duration.inMilliseconds;
    if (frameCount <= 1 || totalMs <= 0) {
      return List<int>.filled(frameCount, 0);
    }

    final lastMs = totalMs - 1;
    return List<int>.generate(frameCount, (index) {
      final position = (lastMs * index / (frameCount - 1)).round();
      return position.clamp(0, lastMs);
    });
  }

  double _calculateFps(Duration duration, int frameCount) {
    final totalMs = duration.inMilliseconds;
    if (frameCount <= 1 || totalMs <= 0) {
      return 1.0;
    }

    final fps = ((frameCount - 1) * 1000) / totalMs;
    return fps.clamp(0.1, 10.0);
  }

  // 解析API响应
  AnalysisResultModel _parseResponse(dynamic responseData) {
    try {
      // 通义千问API响应格式
      if (responseData['output'] != null &&
          responseData['output']['choices'] != null &&
          responseData['output']['choices'].isNotEmpty) {
        final content =
            responseData['output']['choices'][0]['message']['content'][0]['text'];

        // 尝试解析JSON内容
        final jsonStart = content.indexOf('{');
        final jsonEnd = content.lastIndexOf('}') + 1;

        if (jsonStart != -1 && jsonEnd > jsonStart) {
          final jsonStr = content.substring(jsonStart, jsonEnd);
          final jsonData = jsonDecode(jsonStr);

          return AnalysisResultModel(
            items:
                (jsonData['items'] as List?)
                    ?.map((item) => AnalyzedItem.fromJson(item))
                    .toList() ??
                [],
            rawResponse: content,
          );
        }
      }

      // 如果解析失败，返回空结果
      return AnalysisResultModel(
        items: [],
        rawResponse: responseData.toString(),
      );
    } catch (e) {
      throw Exception('解析AI响应失败: $e');
    }
  }

  // 处理Dio错误
  Exception _handleDioError(DioException error) {
    String message;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = '网络连接超时，请检查网络连接';
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          message = 'API Key无效或已过期，请检查设置';
        } else if (statusCode == 429) {
          message = 'API调用次数超限，请稍后再试';
        } else if (statusCode == 500) {
          message = '服务器错误，请稍后再试';
        } else {
          message = '网络请求失败: $statusCode';
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        break;
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          message = '网络连接失败，请检查网络';
        } else {
          message = '未知错误: ${error.error}';
        }
        break;
      default:
        message = '网络请求失败: ${error.message}';
    }

    return Exception(message);
  }

  // 释放资源
  void dispose() {
    _dio.close();
  }
}

class _VideoFramePayload {
  final List<String> frames;
  final double fps;

  const _VideoFramePayload({required this.frames, required this.fps});
}
