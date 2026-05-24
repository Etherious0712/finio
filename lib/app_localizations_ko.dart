// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => '홈';

  @override
  String get transactions => '기록';

  @override
  String get statistics => '통계';

  @override
  String get settings => '설정';

  @override
  String get income => '수입';

  @override
  String get expense => '지출';

  @override
  String get balance => '잔액';

  @override
  String get balanceThisMonth => '이번 달 잔액';

  @override
  String get thisMonth => '이번 달';

  @override
  String get today => '오늘';

  @override
  String get recentTransactions => '최근 거래';

  @override
  String get addTransaction => '기록 추가';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get confirm => '확인';

  @override
  String get amount => '금액';

  @override
  String get note => '메모 (선택, 자동 분류)';

  @override
  String get date => '날짜';

  @override
  String get category => '분류';

  @override
  String get typeLabel => '유형';

  @override
  String get recordTime => '기록 시간';

  @override
  String get noRecords => '아직 기록이 없습니다';

  @override
  String get tapToStart => '+ 를 눌러 시작하세요';

  @override
  String get noMonthlyRecords => '이번 달 기록이 없습니다';

  @override
  String get loadFailed => '불러오기 실패';

  @override
  String get pleaseSelectCategory => '분류를 선택하세요';

  @override
  String get pleaseEnterAmount => '금액을 입력하세요';

  @override
  String get pleaseEnterPositiveAmount => '0보다 큰 금액을 입력하세요';

  @override
  String get budget => '예산';

  @override
  String get monthlyBudget => '월간 예산';

  @override
  String get categoryBudget => '분류 예산';

  @override
  String categoryBudgetLabel(String category) {
    return '$category 예산';
  }

  @override
  String get notSet => '미설정';

  @override
  String get overBudget => '❌ 예산 초과!';

  @override
  String get nearBudget => '⚠️ 예산 한도 근접';

  @override
  String get budgetInputHint => '금액 입력 (비우면 예산 삭제)';

  @override
  String get appearance => '외관';

  @override
  String get language => '언어';

  @override
  String get currency => '통화';

  @override
  String get categoryManagement => '분류 관리';

  @override
  String get budgetSettings => '예산 설정';

  @override
  String get followSystem => '시스템 따름';

  @override
  String get lightMode => '라이트';

  @override
  String get darkMode => '다크';

  @override
  String get searchTransactions => '거래 검색';

  @override
  String get noResults => '결과 없음';

  @override
  String get searchHint => '키워드로 검색';

  @override
  String get last6MonthsTrend => '최근 6개월 추세';

  @override
  String get noData => '데이터 없음';

  @override
  String get totalLabel => '합계';

  @override
  String get noMonthlyExpenseRecords => '이번 달 지출 기록 없음';

  @override
  String get noMonthlyIncomeRecords => '이번 달 수입 기록 없음';

  @override
  String get deleteCategory => '분류 삭제';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return '「$name」을 삭제할까요?';
  }

  @override
  String get noCategoryYet => '분류가 없습니다';

  @override
  String get defaultLabel => '기본';

  @override
  String get categoryName => '분류 이름';

  @override
  String get iconLabel => '아이콘';

  @override
  String get colorLabel => '색상';

  @override
  String get customColor => '커스텀 색상';

  @override
  String get addExpenseCategory => '지출 분류 추가';

  @override
  String get addIncomeCategory => '수입 분류 추가';

  @override
  String get unknownCategory => '알 수 없음';

  @override
  String get confirmCurrencyConvert => '환율 환산을 확인하시겠습니까?';

  @override
  String get fromLabel => '에서';

  @override
  String get toLabel => '로';

  @override
  String get currencyConvertWarning =>
      '모든 거래 금액이 이 환율로 환산됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get confirmConvert => '환산 확인';

  @override
  String currencyConvertSuccess(int count) {
    return '환산 완료, $count개 기록 업데이트';
  }

  @override
  String get currencyNotSupported => '이 통화는 Frankfurter에서 지원되지 않습니다';

  @override
  String get exchangeRateFetchFailed => '환율 조회 실패. 네트워크를 확인하세요.';

  @override
  String get catFood => '외식';

  @override
  String get catTransport => '교통';

  @override
  String get catShopping => '쇼핑';

  @override
  String get catEntertainment => '오락';

  @override
  String get catHealth => '의료';

  @override
  String get catBills => '청구서';

  @override
  String get catOtherExpense => '기타';

  @override
  String get catSalary => '급여';

  @override
  String get catFreelance => '프리랜서';

  @override
  String get catInvestment => '투자';

  @override
  String get catOtherIncome => '기타 수입';
}
