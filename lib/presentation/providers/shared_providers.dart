import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/ai_api_service.dart';
import '../../data/datasources/local/database_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// AI服务Provider
final aiServiceProvider = Provider<AIApiService>((ref) {
  final service = AIApiService();
  ref.onDispose(() => service.dispose());
  return service;
});

// 数据库Provider
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});
