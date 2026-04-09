import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/analysis_result_model.dart';
import '../../data/datasources/remote/ai_api_service.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../core/config/app_config.dart';
import 'shared_providers.dart';

// 分析状态
class AnalysisState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final AnalysisResultModel? result;
  final String? analyzedFilePath;

  const AnalysisState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.result,
    this.analyzedFilePath,
  });

  AnalysisState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    AnalysisResultModel? result,
    String? analyzedFilePath,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      result: result,
      analyzedFilePath: analyzedFilePath,
    );
  }
}

// 分析Provider
class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final AIApiService _aiService;
  final DatabaseHelper _database;

  AnalysisNotifier(this._aiService, this._database)
    : super(const AnalysisState());

  // 分析图片
  Future<void> analyzeImage(String imagePath, String fileType) async {
    // 检查API Key是否已设置
    if (!_aiService.isApiKeySet) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'API Key未设置，请先在设置中配置通义千问API Key',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      // 调用AI API
      final result = await _aiService.analyzeImage(imagePath);

      // 如果配置了自动保存
      if (AppConfig.autoSaveResults && result.items.isNotEmpty) {
        final items = result.toItemModels(imagePath, fileType);
        await _database.insertItems(items);
      }

      state = state.copyWith(
        isLoading: false,
        result: result,
        analyzedFilePath: imagePath,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // 分析视频
  Future<void> analyzeVideo(String videoPath) async {
    if (!_aiService.isApiKeySet) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'API Key未设置，请先在设置中配置通义千问API Key',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      hasError: false,
      errorMessage: null,
    );

    try {
      final result = await _aiService.analyzeVideo(videoPath);

      if (AppConfig.autoSaveResults && result.items.isNotEmpty) {
        final items = result.toItemModels(videoPath, 'video');
        await _database.insertItems(items);
      }

      state = state.copyWith(
        isLoading: false,
        result: result,
        analyzedFilePath: videoPath,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // 重置状态
  void reset() {
    state = const AnalysisState();
  }
}

// 分析Provider
final analysisProvider = StateNotifierProvider<AnalysisNotifier, AnalysisState>(
  (ref) {
    final aiService = ref.watch(aiServiceProvider);
    final database = ref.watch(databaseProvider);
    return AnalysisNotifier(aiService, database);
  },
);
