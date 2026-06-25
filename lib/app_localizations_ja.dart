// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get spendingTrend => '支出の推移';

  @override
  String get editTransaction => '記録を編集';

  @override
  String get groupByDay => '日ごとに表示';

  @override
  String get groupByCategory => 'カテゴリごとに表示';

  @override
  String get vsLastMonth => '先月比';

  @override
  String get recordsUsed => '件';

  @override
  String get editCategory => 'カテゴリを編集';

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => 'ホーム';

  @override
  String get transactions => '記録';

  @override
  String get statistics => '統計';

  @override
  String get settings => '設定';

  @override
  String get income => '収入';

  @override
  String get expense => '支出';

  @override
  String get balance => '残高';

  @override
  String get balanceThisMonth => '今月の残高';

  @override
  String get thisMonth => '今月';

  @override
  String get today => '今日';

  @override
  String get recentTransactions => '最近の取引';

  @override
  String get addTransaction => '記録を追加';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get confirm => '確認';

  @override
  String get amount => '金額';

  @override
  String get note => 'メモ（任意、自動分類）';

  @override
  String get date => '日付';

  @override
  String get category => 'カテゴリ';

  @override
  String get typeLabel => '種別';

  @override
  String get recordTime => '記録時刻';

  @override
  String get noRecords => 'まだ記録がありません';

  @override
  String get tapToStart => '+ をタップして開始';

  @override
  String get noMonthlyRecords => '今月の記録はありません';

  @override
  String get loadFailed => '読み込み失敗';

  @override
  String get pleaseSelectCategory => 'カテゴリを選択してください';

  @override
  String get pleaseEnterAmount => '金額を入力してください';

  @override
  String get pleaseEnterPositiveAmount => '0より大きい金額を入力してください';

  @override
  String get budget => '予算';

  @override
  String get monthlyBudget => '月次予算';

  @override
  String get categoryBudget => 'カテゴリ予算';

  @override
  String categoryBudgetLabel(String category) {
    return '$category 予算';
  }

  @override
  String get notSet => '未設定';

  @override
  String get overBudget => '❌ 予算超過！';

  @override
  String get nearBudget => '⚠️ 予算上限に近い';

  @override
  String get budgetInputHint => '金額を入力（空白で予算削除）';

  @override
  String get appearance => '外観';

  @override
  String get language => '言語';

  @override
  String get currency => '通貨';

  @override
  String get categoryManagement => 'カテゴリ管理';

  @override
  String get budgetSettings => '予算設定';

  @override
  String get followSystem => 'システムに従う';

  @override
  String get lightMode => 'ライト';

  @override
  String get darkMode => 'ダーク';

  @override
  String get searchTransactions => '取引を検索';

  @override
  String get noResults => '結果が見つかりません';

  @override
  String get searchHint => 'キーワードで検索';

  @override
  String get last6MonthsTrend => '過去6ヶ月のトレンド';

  @override
  String get noData => 'データなし';

  @override
  String get totalLabel => '合計';

  @override
  String get noMonthlyExpenseRecords => '今月の支出記録はありません';

  @override
  String get noMonthlyIncomeRecords => '今月の収入記録はありません';

  @override
  String get deleteCategory => 'カテゴリを削除';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get noCategoryYet => 'カテゴリがありません';

  @override
  String get defaultLabel => 'デフォルト';

  @override
  String get categoryName => 'カテゴリ名';

  @override
  String get iconLabel => 'アイコン';

  @override
  String get colorLabel => 'カラー';

  @override
  String get customColor => 'カスタムカラー';

  @override
  String get addExpenseCategory => '支出カテゴリを追加';

  @override
  String get addIncomeCategory => '収入カテゴリを追加';

  @override
  String get unknownCategory => '不明';

  @override
  String get confirmCurrencyConvert => '通貨換算を確認しますか？';

  @override
  String get fromLabel => 'から';

  @override
  String get toLabel => 'へ';

  @override
  String get currencyConvertWarning => '全取引の金額がこのレートで換算されます。この操作は取り消せません。';

  @override
  String get confirmConvert => '換算する';

  @override
  String currencyConvertSuccess(int count) {
    return '換算完了、$count件を更新しました';
  }

  @override
  String get currencyNotSupported => 'この通貨はFrankfurterに対応していません';

  @override
  String get exchangeRateFetchFailed => '為替レートの取得に失敗しました。接続を確認してください。';

  @override
  String get catFood => '食事';

  @override
  String get catTransport => '交通';

  @override
  String get catShopping => '買い物';

  @override
  String get catEntertainment => '娯楽';

  @override
  String get catHealth => '医療';

  @override
  String get catBills => '公共料金';

  @override
  String get catOtherExpense => 'その他';

  @override
  String get catSalary => '給与';

  @override
  String get catFreelance => 'フリーランス';

  @override
  String get catInvestment => '投資';

  @override
  String get catOtherIncome => 'その他収入';

  @override
  String get account => 'アカウント';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get signIn => 'ログイン';

  @override
  String get signUp => '登録';

  @override
  String get skipLogin => 'スキップ';

  @override
  String get checkEmailConfirmation => '登録完了！メールを確認してアカウントを認証してください。';

  @override
  String get cloudSync => 'クラウド同期';

  @override
  String get syncSuccess => '同期完了';

  @override
  String get syncFailed => '同期失敗';

  @override
  String get signOut => 'ログアウト';

  @override
  String get loginForSync => 'デバイス間で同期するにはログインしてください';

  @override
  String get accountAndData => 'アカウントとデータ';

  @override
  String get resetSettings => '設定をリセット';

  @override
  String get resetData => 'データをリセット';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get forgotPassword => 'パスワードを忘れた';

  @override
  String get dangerZone => '危険な操作';

  @override
  String get confirmDelete => 'この操作は元に戻せません。';

  @override
  String get typeDeleteToConfirm => 'DELETE と入力して確認';

  @override
  String get settingsReset => '設定がリセットされました';

  @override
  String get dataReset => 'すべての記録が削除されました';

  @override
  String get accountDeleted => 'アカウントが削除されました';

  @override
  String get resetPasswordEmailSent => 'リセットメールを送信しました。受信トレイを確認してください。';

  @override
  String get dataManagement => 'データ管理';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get currentPassword => '現在のパスワード';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmNewPassword => '新しいパスワード（確認）';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get passwordUpdated => 'パスワードが正常に更新されました';

  @override
  String get incorrectCurrentPassword => '現在のパスワードが正しくありません。再試行してください';

  @override
  String get passwordTooShort => 'パスワードは6文字以上必要です';
}
