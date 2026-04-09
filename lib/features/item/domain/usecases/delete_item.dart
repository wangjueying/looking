import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/item_repository.dart';

class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  Future<Either<Failure, int>> call(int id) {
    return repository.deleteItem(id);
  }
}
