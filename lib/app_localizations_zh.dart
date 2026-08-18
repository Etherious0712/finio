// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get spendingTrend => '支出趋势';

  @override
  String get totalBalance => '总余额';

  @override
  String get editTransaction => '编辑记录';

  @override
  String get groupByMonth => '按月份';

  @override
  String get groupByYear => '按年份';

  @override
  String get groupByCategory => '按类别';

  @override
  String get allTime => '全部时间';

  @override
  String get vsLastMonth => '环比上月';

  @override
  String get recordsUsed => '笔';

  @override
  String get editCategory => '编辑类别';

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => '主页';

  @override
  String get transactions => '记录';

  @override
  String get statistics => '统计';

  @override
  String get settings => '设置';

  @override
  String get income => '收入';

  @override
  String get expense => '支出';

  @override
  String get balance => '结余';

  @override
  String get balanceThisMonth => '本月结余';

  @override
  String get thisMonth => '本月';

  @override
  String get today => '今日';

  @override
  String get recentTransactions => '最近交易';

  @override
  String get addTransaction => '新增记录';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get amount => '金额';

  @override
  String get note => '备注（选填，可自动识别分类）';

  @override
  String get date => '日期';

  @override
  String get category => '分类';

  @override
  String get typeLabel => '类型';

  @override
  String get recordTime => '记录时间';

  @override
  String get noRecords => '还没有记录';

  @override
  String get tapToStart => '点击 + 开始记账';

  @override
  String get noMonthlyRecords => '本月暂无记录';

  @override
  String get noYearlyRecords => '今年暂无记录';

  @override
  String get loadFailed => '加载失败';

  @override
  String get pleaseSelectCategory => '请选择分类';

  @override
  String get pleaseEnterAmount => '请输入金额';

  @override
  String get pleaseEnterPositiveAmount => '请输入大于 0 的金额';

  @override
  String get budget => '预算';

  @override
  String get monthlyBudget => '月度总预算';

  @override
  String get categoryBudget => '分类预算';

  @override
  String categoryBudgetLabel(String category) {
    return '$category 预算';
  }

  @override
  String get notSet => '未设置';

  @override
  String get overBudget => '❌ 已超支';

  @override
  String get nearBudget => '⚠️ 即将超支';

  @override
  String get budgetInputHint => '输入金额（清空则删除预算）';

  @override
  String get appearance => '外观设置';

  @override
  String get language => '语言';

  @override
  String get currency => '货币设置';

  @override
  String get categoryManagement => '分类管理';

  @override
  String get budgetSettings => '预算设置';

  @override
  String get followSystem => '跟随系统';

  @override
  String get lightMode => '浅色';

  @override
  String get darkMode => '深色';

  @override
  String get searchTransactions => '搜索交易记录';

  @override
  String get noResults => '没有找到相关记录';

  @override
  String get searchHint => '输入关键字搜索交易记录';

  @override
  String get last6MonthsTrend => '近6个月趋势';

  @override
  String get noData => '暂无数据';

  @override
  String get totalLabel => '总计';

  @override
  String get noMonthlyExpenseRecords => '本月暂无支出记录';

  @override
  String get noMonthlyIncomeRecords => '本月暂无收入记录';

  @override
  String get deleteCategory => '删除分类';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return '确定要删除「$name」吗？';
  }

  @override
  String get noCategoryYet => '暂无分类';

  @override
  String get defaultLabel => '默认';

  @override
  String get categoryName => '分类名称';

  @override
  String get iconLabel => '图标';

  @override
  String get colorLabel => '颜色';

  @override
  String get customColor => '自定义颜色';

  @override
  String get addExpenseCategory => '新增支出分类';

  @override
  String get addIncomeCategory => '新增收入分类';

  @override
  String get unknownCategory => '未知分类';

  @override
  String get confirmCurrencyConvert => '更改货币？';

  @override
  String get fromLabel => '从';

  @override
  String get toLabel => '到';

  @override
  String get currencyConvertWarning => '已有记录的金额不会换算，仅更改显示的货币符号。';

  @override
  String get confirmConvert => '确认更改';

  @override
  String get curUSD => '美元';

  @override
  String get curSGD => '新加坡元';

  @override
  String get curMYR => '马来西亚令吉';

  @override
  String get curCNY => '人民币';

  @override
  String get curJPY => '日元';

  @override
  String get curEUR => '欧元';

  @override
  String get curGBP => '英镑';

  @override
  String get curKRW => '韩元';

  @override
  String get curTHB => '泰铢';

  @override
  String get curINR => '印度卢比';

  @override
  String get curTWD => '新台币';

  @override
  String get curHKD => '港币';

  @override
  String get curRegionUSD => '美国';

  @override
  String get curRegionSGD => '新加坡';

  @override
  String get curRegionMYR => '马来西亚';

  @override
  String get curRegionCNY => '中国';

  @override
  String get curRegionJPY => '日本';

  @override
  String get curRegionEUR => '欧洲';

  @override
  String get curRegionGBP => '英国';

  @override
  String get curRegionKRW => '韩国';

  @override
  String get curRegionTHB => '泰国';

  @override
  String get curRegionINR => '印度';

  @override
  String get curRegionTWD => '台湾';

  @override
  String get curRegionHKD => '香港';

  @override
  String get catFood => '餐饮';

  @override
  String get catTransport => '交通';

  @override
  String get catShopping => '购物';

  @override
  String get catEntertainment => '娱乐';

  @override
  String get catHealth => '医疗';

  @override
  String get catBills => '账单';

  @override
  String get catOtherExpense => '其他';

  @override
  String get catSalary => '薪资';

  @override
  String get catFreelance => '兼职';

  @override
  String get catInvestment => '投资';

  @override
  String get catOtherIncome => '其他收入';

  @override
  String get account => '账户';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get skipLogin => '跳过';

  @override
  String get checkEmailConfirmation => '注册成功！请检查邮箱以确认账号。';

  @override
  String get cloudSync => '云端同步';

  @override
  String get syncSuccess => '同步成功';

  @override
  String get syncFailed => '同步失败';

  @override
  String get signOut => '退出登录';

  @override
  String get loginForSync => '登录以在设备间同步数据';

  @override
  String get accountAndData => '账号与数据';

  @override
  String get resetSettings => '重置设置';

  @override
  String get resetData => '重置数据';

  @override
  String get deleteAccount => '删除账号';

  @override
  String get forgotPassword => '忘记密码';

  @override
  String get dangerZone => '危险操作';

  @override
  String get confirmDelete => '此操作无法撤销。';

  @override
  String get typeDeleteToConfirm => '输入 DELETE 确认';

  @override
  String get settingsReset => '设置已重置';

  @override
  String get dataReset => '所有记录已清空';

  @override
  String get accountDeleted => '账号已删除';

  @override
  String get resetPasswordEmailSent => '重置邮件已发送，请检查收件箱。';

  @override
  String get dataManagement => '数据管理';

  @override
  String get changePassword => '修改密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmNewPassword => '确认新密码';

  @override
  String get passwordsDoNotMatch => '两次密码不一致';

  @override
  String get passwordUpdated => '密码已成功更新';

  @override
  String get incorrectCurrentPassword => '旧密码不正确，请重试';

  @override
  String get passwordTooShort => '密码不能少于 6 位';

  @override
  String get accounts => '账户';

  @override
  String get accountLabel => '账户';

  @override
  String get addAccount => '添加账户';

  @override
  String get editAccount => '编辑账户';

  @override
  String get accountName => '账户名称';

  @override
  String get setAsDefaultAccount => '设为默认';

  @override
  String get unassignedAccount => '未分配';

  @override
  String get noAccountYet => '暂无账户';

  @override
  String get accountType => '账户类型';

  @override
  String get acctCash => '现金';

  @override
  String get acctBank => '银行卡';

  @override
  String get acctCreditCard => '信用卡';

  @override
  String get acctEWallet => '电子钱包';

  @override
  String get acctSavings => '储蓄';

  @override
  String get openingBalance => '期初余额';

  @override
  String get amountOwed => '欠款金额';

  @override
  String get duplicateAccountName => '已存在同名账户';

  @override
  String get transfer => '转账';

  @override
  String get catTransfer => '转账';

  @override
  String get fromAccount => '转出账户';

  @override
  String get toAccount => '转入账户';

  @override
  String get needTwoAccountsForTransfer => '至少需要两个账户才能转账';

  @override
  String get sameAccountTransfer => '请选择两个不同的账户';
}
