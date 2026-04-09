import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/datasources/local_item_datasource.dart';
import '../../data/datasources/remote_item_datasource.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../domain/usecases/identify_item.dart';
import '../../domain/usecases/get_items.dart';
import '../../domain/usecases/search_items.dart';
import '../../domain/usecases/delete_item.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/item.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Local Data Source Provider
final localItemDataSourceProvider = Provider<LocalItemDataSource>((ref) {
  return LocalItemDataSource();
});

// Remote Data Source Provider
final remoteItemDataSourceProvider = Provider<RemoteItemDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RemoteItemDataSource(apiClient: apiClient);
});

// Repository Provider
final itemRepositoryProvider = Provider<ItemRepositoryImpl>((ref) {
  return ItemRepositoryImpl(
    localDataSource: ref.watch(localItemDataSourceProvider),
    remoteDataSource: ref.watch(remoteItemDataSourceProvider),
    apiClient: ref.watch(apiClientProvider),
  );
});

// Use Case Providers
final identifyItemProvider = Provider<IdentifyItem>((ref) {
  return IdentifyItem(ref.watch(itemRepositoryProvider));
});

final getItemsProvider = Provider<GetItems>((ref) {
  return GetItems(ref.watch(itemRepositoryProvider));
});

final searchItemsProvider = Provider<SearchItems>((ref) {
  return SearchItems(ref.watch(itemRepositoryProvider));
});

final deleteItemProvider = Provider<DeleteItem>((ref) {
  return DeleteItem(ref.watch(itemRepositoryProvider));
});

// Items State
class ItemsState {
  final List<Item> items;
  final bool isLoading;
  final String? error;

  ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Items Notifier
class ItemsNotifier extends StateNotifier<ItemsState> {
  final GetItems _getItems;
  final SearchItems _searchItems;
  final DeleteItem _deleteItem;

  ItemsNotifier({
    required GetItems getItems,
    required SearchItems searchItems,
    required DeleteItem deleteItem,
  })  : _getItems = getItems,
        _searchItems = searchItems,
        _deleteItem = deleteItem,
        super(ItemsState()) {
    loadItems();
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getItems();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (items) => state = state.copyWith(
        items: items,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<void> searchItems(String query) async {
    if (query.isEmpty) {
      loadItems();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await _searchItems(query);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (items) => state = state.copyWith(
        items: items,
        isLoading: false,
        error: null,
      ),
    );
  }

  Future<void> deleteItem(int id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _deleteItem(id);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.toString(),
      ),
      (_) => loadItems(),
    );
  }
}

// Items Provider
final itemsProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  return ItemsNotifier(
    getItems: ref.watch(getItemsProvider),
    searchItems: ref.watch(searchItemsProvider),
    deleteItem: ref.watch(deleteItemProvider),
  );
});

// API Key Provider
class ApiKeyNotifier extends StateNotifier<String?> {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;

  ApiKeyNotifier(this._apiClient, this._storage) : super(null) {
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final apiKey = await _storage.read(key: 'api_key');
    state = apiKey;
    if (apiKey != null) {
      _apiClient.setApiKey(apiKey);
    }
  }

  Future<void> setApiKey(String apiKey) async {
    await _storage.write(key: 'api_key', value: apiKey);
    state = apiKey;
    _apiClient.setApiKey(apiKey);
  }

  Future<void> clearApiKey() async {
    await _storage.delete(key: 'api_key');
    state = null;
  }
}

final apiKeyProvider = StateNotifierProvider<ApiKeyNotifier, String?>((ref) {
  return ApiKeyNotifier(
    ref.watch(apiClientProvider),
    const FlutterSecureStorage(),
  );
});
