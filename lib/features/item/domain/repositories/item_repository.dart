import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';

abstract class ItemRepository {
  Future<Either<Failure, Item>> identifyItem({
    required String filePath,
    required String fileType,
  });

  Future<Either<Failure, List<Item>>> getItems();

  Future<Either<Failure, Item?>> getItemById(int id);

  Future<Either<Failure, List<Item>>> searchItems(String query);

  Future<Either<Failure, int>> deleteItem(int id);

  Future<Either<Failure, int>> deleteAllItems();
}
