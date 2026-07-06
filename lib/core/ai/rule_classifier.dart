import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum TransactionType { income, expense }

class RuleClassifier {
  static const _prefsKey = 'classifier_corrections';

  static const _expenseRules = <String, List<String>>{
    'catFood': ['餐厅', '咖啡', '外卖', '食物', '午餐', '晚餐', '麦当劳', '肯德基', '星巴克', '饭',
               'restaurant', 'cafe', 'food', 'lunch', 'dinner', 'makan'],
    'catTransport': ['grab', '打车', '油钱', '停车', '公交', '地铁', '的士', '滴滴', '高铁', '机票',
                    'taxi', 'bus', 'train', 'mrt', 'lrt', 'petrol'],
    'catShopping': ['shopee', 'lazada', '超市', '便利店', '淘宝', '京东', '购物',
                   'supermarket', 'grocery', 'mall'],
    'catEntertainment': ['netflix', '电影', '游戏', 'ktv', 'spotify', '演唱会', '票',
                        'movie', 'game', 'cinema'],
    'catHealth': ['药', '医院', '诊所', '体检', '手术',
                 'pharmacy', 'hospital', 'clinic', 'doctor'],
    'catBills': ['水电', '电话费', '网络', '房租', '物业', '宽带',
                'rent', 'utilities', 'internet', 'phone'],
  };

  static const _incomeRules = <String, List<String>>{
    'catSalary': ['工资', '薪水', 'salary', '月薪', '年终奖', 'gaji'],
    'catFreelance': ['兼职', 'freelance', '外快', '稿费', '咨询费'],
    'catInvestment': ['股息', '利息', '分红', '股票', '基金', '理财',
                     'dividend', 'interest', 'investment'],
  };

  final Map<String, String> _corrections = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _corrections
        ..clear()
        ..addAll(decoded.cast<String, String>());
    }
  }

  static String classify({
    required String title,
    double? amount,
    required TransactionType type,
  }) {
    return _matchKeywords(title, type);
  }

  String classifyWithLearning({
    required String title,
    required TransactionType type,
  }) {
    final correction = _corrections[title.toLowerCase()];
    if (correction != null) return correction;
    return _matchKeywords(title, type);
  }

  /// The keyword in [title] that triggers a match for [type], or null if none.
  /// Used as the auto-created sub-category name.
  static String? matchedKeyword({
    required String title,
    required TransactionType type,
  }) {
    final lower = title.toLowerCase();
    final rules =
        type == TransactionType.expense ? _expenseRules : _incomeRules;
    for (final entry in rules.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword.toLowerCase())) return keyword;
      }
    }
    return null;
  }

  Future<void> learnCorrection({
    required String original,
    required String correctedCategory,
  }) async {
    _corrections[original.toLowerCase()] = correctedCategory;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_corrections));
  }

  static String _matchKeywords(String title, TransactionType type) {
    final lower = title.toLowerCase();
    final rules =
        type == TransactionType.expense ? _expenseRules : _incomeRules;

    for (final entry in rules.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return type == TransactionType.expense ? 'catOtherExpense' : 'catOtherIncome';
  }
}
