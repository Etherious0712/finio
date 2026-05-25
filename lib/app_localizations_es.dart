// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Finio';

  @override
  String get dashboard => 'Inicio';

  @override
  String get transactions => 'Registros';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get settings => 'Configuración';

  @override
  String get income => 'Ingresos';

  @override
  String get expense => 'Gastos';

  @override
  String get balance => 'Balance';

  @override
  String get balanceThisMonth => 'Balance del mes';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get today => 'Hoy';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get addTransaction => 'Agregar registro';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get amount => 'Monto';

  @override
  String get note => 'Nota (opcional, auto-categoría)';

  @override
  String get date => 'Fecha';

  @override
  String get category => 'Categoría';

  @override
  String get typeLabel => 'Tipo';

  @override
  String get recordTime => 'Hora de registro';

  @override
  String get noRecords => 'Sin registros aún';

  @override
  String get tapToStart => 'Toca + para comenzar';

  @override
  String get noMonthlyRecords => 'Sin registros este mes';

  @override
  String get loadFailed => 'Error al cargar';

  @override
  String get pleaseSelectCategory => 'Por favor seleccione una categoría';

  @override
  String get pleaseEnterAmount => 'Por favor ingrese un monto';

  @override
  String get pleaseEnterPositiveAmount => 'El monto debe ser mayor que 0';

  @override
  String get budget => 'Presupuesto';

  @override
  String get monthlyBudget => 'Presupuesto mensual';

  @override
  String get categoryBudget => 'Presupuesto por categoría';

  @override
  String categoryBudgetLabel(String category) {
    return 'Presupuesto $category';
  }

  @override
  String get notSet => 'No establecido';

  @override
  String get overBudget => '❌ ¡Excedido!';

  @override
  String get nearBudget => '⚠️ Cerca del límite';

  @override
  String get budgetInputHint =>
      'Ingrese monto (vacío para eliminar presupuesto)';

  @override
  String get appearance => 'Apariencia';

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get categoryManagement => 'Gestión de categorías';

  @override
  String get budgetSettings => 'Configuración de presupuesto';

  @override
  String get followSystem => 'Seguir sistema';

  @override
  String get lightMode => 'Claro';

  @override
  String get darkMode => 'Oscuro';

  @override
  String get searchTransactions => 'Buscar transacciones';

  @override
  String get noResults => 'Sin resultados';

  @override
  String get searchHint => 'Ingrese una palabra clave';

  @override
  String get last6MonthsTrend => 'Tendencia de los últimos 6 meses';

  @override
  String get noData => 'Sin datos';

  @override
  String get totalLabel => 'Total';

  @override
  String get noMonthlyExpenseRecords => 'Sin gastos este mes';

  @override
  String get noMonthlyIncomeRecords => 'Sin ingresos este mes';

  @override
  String get deleteCategory => 'Eliminar categoría';

  @override
  String confirmDeleteCategoryMsg(String name) {
    return '¿Eliminar \"$name\"?';
  }

  @override
  String get noCategoryYet => 'Sin categorías aún';

  @override
  String get defaultLabel => 'Por defecto';

  @override
  String get categoryName => 'Nombre de categoría';

  @override
  String get iconLabel => 'Ícono';

  @override
  String get colorLabel => 'Color';

  @override
  String get customColor => 'Color personalizado';

  @override
  String get addExpenseCategory => 'Agregar categoría de gasto';

  @override
  String get addIncomeCategory => 'Agregar categoría de ingreso';

  @override
  String get unknownCategory => 'Desconocido';

  @override
  String get confirmCurrencyConvert => '¿Confirmar conversión de moneda?';

  @override
  String get fromLabel => 'De';

  @override
  String get toLabel => 'A';

  @override
  String get currencyConvertWarning =>
      'Todos los montos serán convertidos a esta tasa. Esta acción no se puede deshacer.';

  @override
  String get confirmConvert => 'Confirmar';

  @override
  String currencyConvertSuccess(int count) {
    return 'Conversión completa, $count registros actualizados';
  }

  @override
  String get currencyNotSupported =>
      'Esta moneda no es compatible con Frankfurter';

  @override
  String get exchangeRateFetchFailed =>
      'No se pudo obtener el tipo de cambio. Verifique su conexión.';

  @override
  String get catFood => 'Comida';

  @override
  String get catTransport => 'Transporte';

  @override
  String get catShopping => 'Compras';

  @override
  String get catEntertainment => 'Entretenimiento';

  @override
  String get catHealth => 'Salud';

  @override
  String get catBills => 'Facturas';

  @override
  String get catOtherExpense => 'Otro';

  @override
  String get catSalary => 'Salario';

  @override
  String get catFreelance => 'Autónomo';

  @override
  String get catInvestment => 'Inversión';

  @override
  String get catOtherIncome => 'Otros ingresos';

  @override
  String get account => 'Cuenta';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signUp => 'Registrarse';

  @override
  String get skipLogin => 'Omitir';

  @override
  String get checkEmailConfirmation =>
      '¡Registro exitoso! Revisa tu correo para confirmar tu cuenta.';

  @override
  String get cloudSync => 'Sincronización en la nube';

  @override
  String get syncSuccess => 'Sincronización exitosa';

  @override
  String get syncFailed => 'Error de sincronización';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get loginForSync =>
      'Inicia sesión para sincronizar entre dispositivos';
}
