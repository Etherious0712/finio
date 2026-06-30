import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Currently selected bottom-nav tab index. Shared so any screen can switch
/// tabs (e.g. dashboard graphs jumping to Statistics).
/// 0 = Home, 1 = Records, 2 = Statistics, 3 = Settings.
final navIndexProvider = StateProvider<int>((_) => 0);
