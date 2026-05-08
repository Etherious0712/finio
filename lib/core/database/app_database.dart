import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/category_dao.dart';
import 'daos/transaction_dao.dart';

part 'app_database.g.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(max: 100)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get category => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncId => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 50)();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get icon => text()(); // Material icon name
  TextColumn get color => text()(); // Hex color string
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Transactions, Categories])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  late final transactionDao = TransactionDao(this);
  late final categoryDao = CategoryDao(this);

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedDefaultCategories();
        },
      );

  Future<void> _seedDefaultCategories() async {
    await batch((b) {
      b.insertAll(categories, [
        // 支出类别
        CategoriesCompanion.insert(name: '餐饮', type: 'expense', icon: 'restaurant', color: '#FF6B6B'),
        CategoriesCompanion.insert(name: '交通', type: 'expense', icon: 'directions_transit', color: '#4ECDC4'),
        CategoriesCompanion.insert(name: '购物', type: 'expense', icon: 'shopping_bag', color: '#45B7D1'),
        CategoriesCompanion.insert(name: '娱乐', type: 'expense', icon: 'sports_esports', color: '#96CEB4'),
        CategoriesCompanion.insert(name: '医疗', type: 'expense', icon: 'local_hospital', color: '#FFEAA7'),
        CategoriesCompanion.insert(name: '账单', type: 'expense', icon: 'receipt_long', color: '#DDA0DD'),
        CategoriesCompanion.insert(name: '其他', type: 'expense', icon: 'more_horiz', color: '#B0B0B0'),
        // 收入类别
        CategoriesCompanion.insert(name: '薪资', type: 'income', icon: 'work', color: '#2ECC71'),
        CategoriesCompanion.insert(name: '兼职', type: 'income', icon: 'laptop_mac', color: '#27AE60'),
        CategoriesCompanion.insert(name: '投资', type: 'income', icon: 'trending_up', color: '#F39C12'),
        CategoriesCompanion.insert(name: '其他', type: 'income', icon: 'more_horiz', color: '#95A5A6'),
      ]);
    });
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'finio_db');
}
