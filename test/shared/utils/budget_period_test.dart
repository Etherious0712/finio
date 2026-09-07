import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finio/core/database/app_database.dart';
import 'package:finio/shared/utils/budget_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('budgetWindow', () {
    test('a week runs Monday to Monday, end exclusive', () {
      // 2026-08-13 is a Thursday.
      final (start, end) = budgetWindow('week', DateTime(2026, 8, 13));
      expect(start, DateTime(2026, 8, 10)); // the Monday before
      expect(end, DateTime(2026, 8, 17)); // the next Monday, excluded
      expect(end.difference(start).inDays, 7);
    });

    test('a Monday anchor is its own week start', () {
      final (start, _) = budgetWindow('week', DateTime(2026, 8, 10));
      expect(start, DateTime(2026, 8, 10));
    });

    test('a Sunday anchor belongs to the week that started six days earlier',
        () {
      final (start, _) = budgetWindow('week', DateTime(2026, 8, 16));
      expect(start, DateTime(2026, 8, 10));
    });

    test('December rolls into January of the next year', () {
      final (start, end) = budgetWindow('month', DateTime(2026, 12, 20));
      expect(start, DateTime(2026, 12));
      expect(end, DateTime(2027, 1));
    });

    test('a year runs Jan 1 to Jan 1', () {
      final (start, end) = budgetWindow('year', DateTime(2026, 6, 15));
      expect(start, DateTime(2026));
      expect(end, DateTime(2027));
    });
  });

  group('effectiveBudget', () {
    late AppDatabase db;
    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    Future<Budget> make({
      required String period,
      int month = 0,
      int year = 0,
      double? override,
    }) async {
      final id = await db.budgetDao.insertBudget(BudgetsCompanion.insert(
        amount: 500,
        period: Value(period),
        month: month,
        year: year,
        overrideAmount: Value(override),
      ));
      return (await db.budgetDao.getBudgets()).firstWhere((b) => b.id == id);
    }

    test('uses the override inside the month it names', () async {
      final b = await make(period: 'month', month: 12, year: 2026, override: 1500);
      expect(effectiveBudget(b, DateTime(2026, 12)), 1500);
    });

    test('falls back to the recurring amount in any other month', () async {
      final b = await make(period: 'month', month: 12, year: 2026, override: 1500);
      expect(effectiveBudget(b, DateTime(2026, 11)), 500);
      expect(effectiveBudget(b, DateTime(2027, 12)), 500);
    });

    test('an override left on a yearly budget is inert', () async {
      final b = await make(period: 'year', month: 12, year: 2026, override: 1500);
      expect(effectiveBudget(b, DateTime(2026)), 500);
    });

    test('no override means the recurring amount', () async {
      final b = await make(period: 'month');
      expect(effectiveBudget(b, DateTime(2026, 8)), 500);
    });
  });
}
