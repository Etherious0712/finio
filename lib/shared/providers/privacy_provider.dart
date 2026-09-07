import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the dashboard balance card masks its numbers. Card only — the
/// transaction list below it stays readable.
///
/// Persisted rather than ephemeral: a privacy control that silently un-hides on
/// every cold start is itself a privacy bug.
class HideAmountsNotifier extends StateNotifier<bool> {
  HideAmountsNotifier() : super(false) {
    _load();
  }

  static const _key = 'hide_amounts';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? false;
  }

  Future<void> setHidden(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}

final hideAmountsProvider =
    StateNotifierProvider<HideAmountsNotifier, bool>((_) => HideAmountsNotifier());
