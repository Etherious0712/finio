import 'package:drift/drift.dart';

import '../app_database.dart';

part 'category_dao.g.dart';

@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  CategoryDao(super.db);

  Stream<List<Category>> watchAllCategories() => select(categories).watch();

  Stream<List<Category>> watchCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).watch();

  /// Top-level (main) categories of a type — parent is null.
  Stream<List<Category>> watchMainCategories(String type) =>
      (select(categories)
            ..where((c) => c.type.equals(type) & c.parentId.isNull()))
          .watch();

  /// Sub-categories under a given main.
  Stream<List<Category>> watchSubcategories(int parentId) =>
      (select(categories)..where((c) => c.parentId.equals(parentId))).watch();

  /// Finds a sub-category by (name, parentId), or creates it inheriting the
  /// parent's icon/color. Used by auto-categorization.
  Future<Category> findOrCreateSub({
    required int parentId,
    required String name,
    required String type,
    required String icon,
    required String color,
  }) async {
    final existing = await (select(categories)
          ..where((c) => c.name.equals(name) & c.parentId.equals(parentId)))
        .getSingleOrNull();
    if (existing != null) return existing;
    final id = await into(categories).insert(CategoriesCompanion.insert(
      name: name,
      type: type,
      icon: icon,
      color: color,
      isCustom: const Value(true),
      parentId: Value(parentId),
    ));
    return (select(categories)..where((c) => c.id.equals(id))).getSingle();
  }

  Future<List<Category>> getAllCategories() => select(categories).get();

  Future<List<Category>> getCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).get();

  Future<int> insertCategory(CategoriesCompanion entry) =>
      into(categories).insert(entry);

  Future<bool> updateCategory(Category entry) =>
      update(categories).replace(entry);

  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((c) => c.id.equals(id))).go();

  Future<int> deleteCustomCategories() =>
      (delete(categories)..where((c) => c.isCustom.equals(true))).go();
}
