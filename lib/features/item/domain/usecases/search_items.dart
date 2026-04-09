import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/item.dart';
import '../repositories/item_repository.dart';

class SearchItems {
  final ItemRepository repository;

  SearchItems(this.repository);

  Future<Either<Failure, List<Item>>> call(String query) {
    return repository.searchItems(query);
  }
}
