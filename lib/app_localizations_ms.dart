// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => 'Utama';

  @override
  String get transactions => 'Rekod';

  @override
  String get statistics => 'Statistik';

  @override
  String get settings => 'Tetapan';

  @override
  String get income => 'Pendapatan';

  @override
  String get expense => 'Perbelanjaan';

  @override
  String get balance => 'Baki';

  @override
  String get balanceThisMonth => 'Baki Bulan Ini';

  @override
  String get thisMonth => 'Bulan Ini';

  @override
  String get today => 'Hari Ini';

  @override
  String get recentTransactions => 'Transaksi Terkini';

  @override
  String get addTransaction => 'Tambah Rekod';

  @override
  String get save => 'Simpan';

  @override
  String get cancel => 'Batal';

  @override
  String get delete => 'Padam';

  @override
  String get confirm => 'Sahkan';

  @override
  String get amount => 'Jumlah';

  @override
  String get note => 'Nota (pilihan, auto-kategori)';

  @override
  String get date => 'Tarikh';

  @override
  String get category => 'Kategori';

  @override
  String get typeLabel => 'Jenis';

  @override
  String get recordTime => 'Masa Rekod';

  @override
  String get noRecords => 'Tiada rekod lagi';

  @override
  String get tapToStart => 'Ketuk + untuk mula';

  @override
  String get noMonthlyRecords => 'Tiada rekod bulan ini';

  @override
  String get loadFailed => 'Gagal dimuatkan';

  @override
  String get pleaseSelectCategory => 'Sila pilih kategori';

  @override
  String get pleaseEnterAmount => 'Sila masukkan jumlah';

  @override
  String get pleaseEnterPositiveAmount => 'Jumlah mesti lebih dari 0';

  @override
  String get budget => 'Belanjawan';

  @override
  String get monthlyBudget => 'Belanjawan Bulanan';

  @override
  String get categoryBudget => 'Belanjawan Kategori';

  @override
  String categoryBudgetLabel(String category) {
    return 'Belanjawan $category';
  }

  @override
  String get notSet => 'Belum ditetapkan';

  @override
  String get overBudget => '❌ Melebihi belanjawan!';

  @override
  String get nearBudget => '⚠️ Hampir melebihi had';

  @override
  String get budgetInputHint =>
      'Masukkan jumlah (kosongkan untuk hapus belanjawan)';

  @override
  String get appearance => 'Penampilan';

  @override
  String get language => 'Bahasa';

  @override
  String get currency => 'Mata Wang';

  @override
  String get categoryManagement => 'Pengurusan Kategori';

  @override
  String get budgetSettings => 'Tetapan Belanjawan';

  @override
  String get followSystem => 'Ikut Sistem';

  @override
  String get lightMode => 'Cerah';

  @override
  String get darkMode => 'Gelap';

  @override
  String get searchTransactions => 'Cari transaksi';

  @override
  String get noResults => 'Tiada keputusan';

  @override
  String get searchHint => 'Masukkan kata kunci untuk cari';

  @override
  String get last6MonthsTrend => 'Trend 6 Bulan Lepas';

  @override
  String get noData => 'Tiada data';

  @override
  String get totalLabel => 'Jumlah';

  @override
  String get noMonthlyExpenseRecords => 'Tiada rekod perbelanjaan bulan ini';

  @override
  String get noMonthlyIncomeRecords => 'Tiada rekod pendapatan bulan ini';

  @override
  String get deleteCategory => 'Padam Kategori';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return 'Padam \"$name\"?';
  }

  @override
  String get noCategoryYet => 'Tiada kategori lagi';

  @override
  String get defaultLabel => 'Lalai';

  @override
  String get categoryName => 'Nama Kategori';

  @override
  String get iconLabel => 'Ikon';

  @override
  String get colorLabel => 'Warna';

  @override
  String get customColor => 'Warna Tersuai';

  @override
  String get addExpenseCategory => 'Tambah Kategori Perbelanjaan';

  @override
  String get addIncomeCategory => 'Tambah Kategori Pendapatan';

  @override
  String get unknownCategory => 'Tidak diketahui';

  @override
  String get confirmCurrencyConvert => 'Sahkan penukaran mata wang?';

  @override
  String get fromLabel => 'Dari';

  @override
  String get toLabel => 'Ke';

  @override
  String get currencyConvertWarning =>
      'Semua jumlah transaksi akan ditukar mengikut kadar ini. Tindakan ini tidak boleh dibatalkan.';

  @override
  String get confirmConvert => 'Sahkan';

  @override
  String currencyConvertSuccess(int count) {
    return 'Penukaran selesai, $count rekod dikemas kini';
  }

  @override
  String get currencyNotSupported =>
      'Mata wang ini tidak disokong oleh Frankfurter';

  @override
  String get exchangeRateFetchFailed =>
      'Gagal mendapatkan kadar pertukaran. Semak sambungan anda.';

  @override
  String get catFood => 'Makanan';

  @override
  String get catTransport => 'Pengangkutan';

  @override
  String get catShopping => 'Membeli-belah';

  @override
  String get catEntertainment => 'Hiburan';

  @override
  String get catHealth => 'Kesihatan';

  @override
  String get catBills => 'Bil';

  @override
  String get catOtherExpense => 'Lain-lain';

  @override
  String get catSalary => 'Gaji';

  @override
  String get catFreelance => 'Bebas';

  @override
  String get catInvestment => 'Pelaburan';

  @override
  String get catOtherIncome => 'Pendapatan Lain';
}
