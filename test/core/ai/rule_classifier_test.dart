import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finio/core/ai/rule_classifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RuleClassifier.classify — 支出分类', () {
    test('餐饮关键词', () {
      for (final title in ['麦当劳外卖', '星巴克咖啡', '午餐', '外卖订单', '晚餐聚餐']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.expense),
          'catFood',
          reason: '"$title" 应分类为餐饮',
        );
      }
    });

    test('交通关键词', () {
      for (final title in ['Grab打车', '地铁充值', '停车费', '高铁票']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.expense),
          'catTransport',
          reason: '"$title" 应分类为交通',
        );
      }
    });

    test('购物关键词', () {
      for (final title in ['Shopee订单', 'Lazada购物', '超市采购', '便利店']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.expense),
          'catShopping',
          reason: '"$title" 应分类为购物',
        );
      }
    });

    test('娱乐关键词', () {
      for (final title in ['Netflix订阅', '电影票', '游戏充值', 'KTV']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.expense),
          'catEntertainment',
          reason: '"$title" 应分类为娱乐',
        );
      }
    });

    test('医疗关键词', () {
      for (final title in ['药店购药', '医院挂号', '诊所就诊', '体检费']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.expense),
          'catHealth',
          reason: '"$title" 应分类为医疗',
        );
      }
    });

    test('账单关键词', () {
      for (final title in ['房租', '电话费', '水电费', '宽带费']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.expense),
          'catBills',
          reason: '"$title" 应分类为账单',
        );
      }
    });

    test('未匹配时兜底为其他', () {
      expect(
        RuleClassifier.classify(title: '未知消费', type: TransactionType.expense),
        'catOtherExpense',
      );
    });
  });

  group('RuleClassifier.classify — 收入分类', () {
    test('薪资关键词', () {
      for (final title in ['工资发放', '薪水到账', 'Monthly salary', '年终奖']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.income),
          'catSalary',
          reason: '"$title" 应分类为薪资',
        );
      }
    });

    test('兼职关键词', () {
      for (final title in ['Freelance项目', '兼职收入', '稿费到账']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.income),
          'catFreelance',
          reason: '"$title" 应分类为兼职',
        );
      }
    });

    test('投资关键词', () {
      for (final title in ['股息收入', '利息到账', '基金分红']) {
        expect(
          RuleClassifier.classify(title: title, type: TransactionType.income),
          'catInvestment',
          reason: '"$title" 应分类为投资',
        );
      }
    });

    test('未匹配收入兜底为其他', () {
      expect(
        RuleClassifier.classify(title: '红包', type: TransactionType.income),
        'catOtherIncome',
      );
    });
  });

  group('RuleClassifier.classify — 大小写不敏感', () {
    test('英文关键词大小写无关', () {
      expect(
        RuleClassifier.classify(title: 'NETFLIX月费', type: TransactionType.expense),
        'catEntertainment',
      );
      expect(
        RuleClassifier.classify(title: 'SALARY received', type: TransactionType.income),
        'catSalary',
      );
      expect(
        RuleClassifier.classify(title: 'GRAB ride', type: TransactionType.expense),
        'catTransport',
      );
    });
  });

  group('RuleClassifier.matchedKeyword', () {
    test('returns the keyword that fired the match (used as sub name)', () {
      expect(
        RuleClassifier.matchedKeyword(
            title: 'team lunch', type: TransactionType.expense),
        'lunch',
      );
      expect(
        RuleClassifier.matchedKeyword(
            title: 'GRAB ride home', type: TransactionType.expense),
        'grab',
      );
      expect(
        RuleClassifier.matchedKeyword(
            title: 'Netflix monthly', type: TransactionType.expense),
        'netflix',
      );
    });

    test('returns null when nothing matches', () {
      expect(
        RuleClassifier.matchedKeyword(
            title: 'zzzz', type: TransactionType.expense),
        isNull,
      );
    });
  });

  group('RuleClassifier — 学习纠正', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('纠正前后分类结果不同', () async {
      final classifier = RuleClassifier();

      expect(
        classifier.classifyWithLearning(title: '转账给朋友', type: TransactionType.expense),
        'catOtherExpense',
      );

      await classifier.learnCorrection(
        original: '转账给朋友',
        correctedCategory: 'catFood',
      );

      expect(
        classifier.classifyWithLearning(title: '转账给朋友', type: TransactionType.expense),
        'catFood',
      );
    });

    test('纠正记录持久化后可被新实例加载', () async {
      final c1 = RuleClassifier();
      await c1.learnCorrection(original: '特殊支出', correctedCategory: 'catEntertainment');

      final c2 = RuleClassifier();
      await c2.load();
      expect(
        c2.classifyWithLearning(title: '特殊支出', type: TransactionType.expense),
        'catEntertainment',
      );
    });

    test('纠正匹配不区分大小写', () async {
      final classifier = RuleClassifier();
      await classifier.learnCorrection(
        original: 'PayPal转账',
        correctedCategory: 'catFreelance',
      );

      expect(
        classifier.classifyWithLearning(title: 'PayPal转账', type: TransactionType.income),
        'catFreelance',
      );
      expect(
        classifier.classifyWithLearning(title: 'paypal转账', type: TransactionType.income),
        'catFreelance',
      );
    });

    test('纠正不影响 static classify', () async {
      final classifier = RuleClassifier();
      await classifier.learnCorrection(
        original: '神秘支出',
        correctedCategory: 'catHealth',
      );

      // static 方法不受实例纠正影响
      expect(
        RuleClassifier.classify(title: '神秘支出', type: TransactionType.expense),
        'catOtherExpense',
      );
    });
  });
}
