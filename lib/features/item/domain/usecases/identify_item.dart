import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

class IdentifyItem {
  final ItemRepository repository;

  IdentifyItem(this.repository);

  Future<Either<Failure, Item>> call({
    required String filePath,
    required String fileType,
  }) {
    return repository.identifyItem(
      filePath: filePath,
      fileType: fileType,
    );
  }
}
