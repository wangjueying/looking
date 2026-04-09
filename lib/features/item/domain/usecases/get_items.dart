import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  Future<Either<Failure, List<Item>>> call() {
    return repository.getItems();
  }
}
