import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/remote/ai_api_service.dart';
import '../../core/config/app_config.dart';
import 'shared_providers.dart';

// 设置状态
class SettingsState {
  final String? apiKey;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  const SettingsState({
    this.apiKey,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  SettingsState copyWith({
    String? apiKey,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return SettingsState(
      apiKey: apiKey ?? this.apiKey,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
    );
  }
}

// 设置Provider
class SettingsNotifier extends StateNotifier<SettingsState> {
  final FlutterSecureStorage _storage;
  final AIApiService _aiService;

  SettingsNotifier(this._storage, this._aiService)
      : super(const SettingsState()) {
    _loadApiKey();
  }

  // 加载API Key
  Future<void> _loadApiKey() async {
    state = state.copyWith(isLoading: true);
    try {
      final apiKey =
          (await _storage.read(key: AppConfig.apiKeyStorageKey))?.trim();

      if (apiKey != null && apiKey.isNotEmpty) {
        _aiService.setApiKey(apiKey);
      } else {
        _aiService.clearApiKey();
      }

      state = state.copyWith(
        apiKey: apiKey?.isEmpty == true ? null : apiKey,
        isLoading: false,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      _aiService.clearApiKey();
      state = state.copyWith(
        apiKey: null,
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // 确保API Key已加载（公共方法）
  Future<void> loadApiKeyIfNeeded() async {
    if (!state.isLoading && state.apiKey == null) {
      await _loadApiKey();
    }
  }

  // 保存API Key
  Future<void> saveApiKey(String apiKey) async {
    final normalizedApiKey = apiKey.trim();
    if (normalizedApiKey.isEmpty) {
      await clearApiKey();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      await _storage.write(
        key: AppConfig.apiKeyStorageKey,
        value: normalizedApiKey,
      );
      _aiService.setApiKey(normalizedApiKey);
      state = state.copyWith(
        apiKey: normalizedApiKey,
        isLoading: false,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // 清除API Key
  Future<void> clearApiKey() async {
    state = state.copyWith(isLoading: true);
    try {
      await _storage.delete(key: AppConfig.apiKeyStorageKey);
      _aiService.clearApiKey();
      state = state.copyWith(
        apiKey: null,
        isLoading: false,
        hasError: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }
}

// 设置Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final storage = ref.watch(secureStorageProvider);
    final aiService = ref.watch(aiServiceProvider);
    return SettingsNotifier(storage, aiService);
  },
);
