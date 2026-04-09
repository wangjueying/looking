import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/item_model.dart';
import '../../data/datasources/local/database_helper.dart';
import 'shared_providers.dart';

// 物品列表状态
class ItemsState {
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final List<ItemModel> items;

  const ItemsState({
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.items = const [],
  });

  ItemsState copyWith({
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    List<ItemModel>? items,
  }) {
    return ItemsState(
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      items: items ?? this.items,
    );
  }
}

// 物品Provider
class ItemsNotifier extends StateNotifier<ItemsState> {
  final DatabaseHelper _database;

  ItemsNotifier(this._database) : super(const ItemsState());

  // 加载所有物品
  Future<void> loadAllItems() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _database.getAllItems();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // 搜索物品
  Future<void> searchItems(String query) async {
    if (query.isEmpty) {
      await loadAllItems();
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final items = await _database.searchItems(query);
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  // 获取统计信息
  Future<Map<String, dynamic>> getStats() async {
    try {
      final itemCount = await _database.getItemCount();
      final typeCount = await _database.getItemTypeCount();
      return {'itemCount': itemCount, 'typeCount': typeCount};
    } catch (e) {
      return {'itemCount': 0, 'typeCount': 0};
    }
  }

  // 从物品清单移除物品，但保留搜索历史
  Future<void> deleteItem(int id) async {
    try {
      await _database.deleteItem(id);
      await loadAllItems();
    } catch (e) {
      state = state.copyWith(hasError: true, errorMessage: e.toString());
    }
  }

  // 恢复物品到清单
  Future<void> restoreItem(int id) async {
    try {
      await _database.restoreItem(id);
      await loadAllItems();
    } catch (e) {
      state = state.copyWith(hasError: true, errorMessage: e.toString());
    }
  }

  // 清空所有物品
  Future<void> clearAll() async {
    try {
      await _database.deleteAllItems();
      state = state.copyWith(items: []);
    } catch (e) {
      state = state.copyWith(hasError: true, errorMessage: e.toString());
    }
  }
}

// 物品Provider
final itemsProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  final database = ref.watch(databaseProvider);
  return ItemsNotifier(database);
});

// 统计信息Provider
final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final notifier = ref.watch(itemsProvider.notifier);
  return await notifier.getStats();
});
