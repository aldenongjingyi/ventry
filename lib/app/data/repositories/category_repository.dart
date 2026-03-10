import '../models/category_model.dart';
import '../providers/category_provider.dart';

class CategoryRepository {
  final CategoryProvider _provider;

  CategoryRepository({CategoryProvider? provider})
      : _provider = provider ?? CategoryProvider();

  Future<List<CategoryModel>> getAll() async {
    final data = await _provider.getAll();
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }
}
