import 'package:flutter/material.dart';

IconData categoryIconData(String iconName) {
  const map = <String, IconData>{
    'restaurant': Icons.restaurant,
    'directions_transit': Icons.directions_transit,
    'shopping_bag': Icons.shopping_bag,
    'sports_esports': Icons.sports_esports,
    'local_hospital': Icons.local_hospital,
    'receipt_long': Icons.receipt_long,
    'more_horiz': Icons.more_horiz,
    'work': Icons.work,
    'laptop_mac': Icons.laptop_mac,
    'trending_up': Icons.trending_up,
  };
  return map[iconName] ?? Icons.label;
}
