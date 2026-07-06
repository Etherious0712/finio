import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/database_provider.dart';

/// All categories (live stream).
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchAllCategories();
});

/// Categories filtered by type (family provider).
/// Usage: ref.watch(categoriesByTypeProvider('expense'))
final categoriesByTypeProvider =
    StreamProvider.autoDispose.family<List<Category>, String>((ref, type) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchCategoriesByType(type);
});

/// Main (top-level) expense categories — used by the transaction pickers.
final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchMainCategories('expense');
});

/// Main (top-level) income categories — used by the transaction pickers.
final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchMainCategories('income');
});

/// Sub-categories under a given main category id.
final subcategoriesProvider =
    StreamProvider.autoDispose.family<List<Category>, int>((ref, parentId) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchSubcategories(parentId);
});

/// Maps every category leaf ('type:name') to the name of its MAIN category, so
/// transactions filed under a sub can be rolled up. Mains map to themselves.
final categoryMainKeyProvider = Provider<Map<String, String>>((ref) {
  final cats = ref.watch(allCategoriesProvider).valueOrNull ?? [];
  final byId = {for (final c in cats) c.id: c};
  return {
    for (final c in cats)
      '${c.type}:${c.name}':
          c.parentId == null ? c.name : (byId[c.parentId]?.name ?? c.name),
  };
});
