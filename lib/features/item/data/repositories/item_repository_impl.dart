import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/local_item_datasource.dart';
import '../datasources/remote_item_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import 'package:dartz/dartz.dart';

class ItemRepositoryImpl implements ItemRepository {
  final LocalItemDataSource localDataSource;
  final RemoteItemDataSource remoteDataSource;
  final ApiClient apiClient;

  ItemRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, Item>> identifyItem({
    required String filePath,
    required String fileType,
  }) async {
    try {
      // Check if API key is configured
      if (!apiClient.hasDefaultHeaders()) {
        return Left(PermissionFailure('API Key not configured'));
      }

      final itemModel = await remoteDataSource.identifyItem(
        filePath: filePath,
        fileType: fileType,
      );

      // Save to local database
      final savedItem = await localDataSource.insertItem(itemModel);

      return Right(savedItem.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getItems() async {
    try {
      final items = await localDataSource.getAllItems();
      return Right(items.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get items: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Item?>> getItemById(int id) async {
    try {
      final item = await localDataSource.getItemById(id);
      return Right(item?.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> searchItems(String query) async {
    try {
      final items = await localDataSource.searchItems(query);
      return Right(items.map((model) => model.toEntity()).toList());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to search items: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteItem(int id) async {
    try {
      final result = await localDataSource.deleteItem(id);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete item: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteAllItems() async {
    try {
      final result = await localDataSource.deleteAllItems();
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to delete all items: ${e.toString()}'));
    }
  }
}
