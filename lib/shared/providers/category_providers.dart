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

/// Expense categories (shortcut provider).
final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchCategoriesByType('expense');
});

/// Income categories (shortcut provider).
final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchCategoriesByType('income');
});
