import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/providers/database_provider.dart';

/// 所有分类列表（实时 Stream）
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchAllCategories();
});

/// 按类型筛选分类，通用 family provider
/// 用法：ref.watch(categoriesByTypeProvider('expense'))
final categoriesByTypeProvider =
    StreamProvider.autoDispose.family<List<Category>, String>((ref, type) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchCategoriesByType(type);
});

/// 支出分类列表（快捷 Provider）
final expenseCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchCategoriesByType('expense');
});

/// 收入分类列表（快捷 Provider）
final incomeCategoriesProvider =
    StreamProvider.autoDispose<List<Category>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.categoryDao.watchCategoriesByType('income');
});
