import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/exchange_rate_service.dart';
import '../../shared/providers/currency_provider.dart';
import '../../shared/providers/database_provider.dart';

class CurrencyScreen extends ConsumerStatefulWidget {
  const CurrencyScreen({super.key});

  @override
  ConsumerState<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends ConsumerState<CurrencyScreen> {
  bool _loading = false;

  // (code, symbol, name, region)
  static const _kOptions = [
    ('USD', r'$',    '美元',        'USD · 美国'),
    ('SGD', r'$',    '新加坡元',    'SGD · 新加坡'),
    ('MYR', 'RM',   '马来西亚令吉', 'MYR · 马来西亚'),
    ('CNY', '¥',    '人民币',      'CNY · 中国'),
    ('JPY', '¥',    '日元',        'JPY · 日本'),
    ('EUR', '€',    '欧元',        'EUR · 欧洲'),
    ('GBP', '£',    '英镑',        'GBP · 英国'),
    ('KRW', '₩',    '韩元',        'KRW · 韩国'),
    ('THB', '฿',    '泰铢',        'THB · 泰国'),
    ('INR', '₹',    '印度卢比',    'INR · 印度'),
    ('TWD', r'NT$', '新台币',      'TWD · 台湾'),
    ('HKD', r'HK$', '港币',        'HKD · 香港'),
  ];

  static (String, String, String, String)? _option(String code) {
    for (final o in _kOptions) {
      if (o.$1 == code) return o;
    }
    return null;
  }

  Future<void> _handleSelection(String newCode) async {
    final currentCode = ref.read(currencyProvider);
    if (newCode == currentCode || _loading) return;

    setState(() => _loading = true);
    try {
      final rate = await ExchangeRateService.getRate(currentCode, newCode);
      if (!mounted) return;

      final from = _option(currentCode);
      final to = _option(newCode);
      final fromLabel = from != null ? '$currentCode（${from.$2} ${from.$3}）' : currentCode;
      final toLabel   = to   != null ? '$newCode（${to.$2} ${to.$3}）'         : newCode;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('确认换算货币？'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(label: '从', value: fromLabel),
              _InfoRow(label: '到', value: toLabel),
              const SizedBox(height: 10),
              Text(
                '当前汇率：1 $currentCode = ${rate.toStringAsFixed(4)} $newCode',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '数据来源：Frankfurter，每日更新',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '所有历史记录的金额将根据此汇率换算，此操作无法撤销。',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('确认换算'),
            ),
          ],
        ),
      );

      if (!mounted || confirmed != true) return;

      final db = ref.read(appDatabaseProvider);
      final count = await db.transactionDao.updateAllAmounts(rate);
      await ref.read(currencyProvider.notifier).setCode(newCode);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已完成换算，共更新 $count 笔记录')),
      );
    } on UnsupportedError {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该货币暂不支持汇率查询（Frankfurter 不提供此货币数据）')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('获取汇率失败，请检查网络连接')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('货币设置'), centerTitle: true),
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _loading,
            child: RadioGroup<String>(
              groupValue: currentCode,
              onChanged: (v) => _handleSelection(v!),
              child: ListView(
                children: [
                  for (final (code, symbol, name, region) in _kOptions)
                    RadioListTile<String>(
                      value: code,
                      title: Text('$symbol  $name'),
                      subtitle: Text(region),
                    ),
                ],
              ),
            ),
          ),
          if (_loading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$label：',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
