import 'package:flutter/material.dart';

const kPresetColors = <String>[
  '#EF5350', '#FF7043', '#FF9800', '#FFCA28',
  '#66BB6A', '#26A69A', '#42A5F5', '#7E57C2',
  '#EC407A', '#78909C', '#26C6DA', '#D4E157',
];

const kPickableIcons = <String, IconData>{
  // Food & dining
  'restaurant': Icons.restaurant,
  'coffee': Icons.coffee,
  'local_cafe': Icons.local_cafe,
  'fastfood': Icons.fastfood,
  'bakery_dining': Icons.bakery_dining,
  'lunch_dining': Icons.lunch_dining,
  'dinner_dining': Icons.dinner_dining,
  'ramen_dining': Icons.ramen_dining,
  'liquor': Icons.liquor,
  'cake': Icons.cake,
  'local_pizza': Icons.local_pizza,
  'icecream': Icons.icecream,
  'wine_bar': Icons.wine_bar,
  'local_bar': Icons.local_bar,
  // Transport
  'directions_car': Icons.directions_car,
  'directions_bus': Icons.directions_bus,
  'train': Icons.train,
  'subway': Icons.subway,
  'flight': Icons.flight,
  'local_taxi': Icons.local_taxi,
  'two_wheeler': Icons.two_wheeler,
  'electric_car': Icons.electric_car,
  'pedal_bike': Icons.pedal_bike,
  'sailing': Icons.sailing,
  'directions_transit': Icons.directions_transit,
  'local_gas_station': Icons.local_gas_station,
  'directions_walk': Icons.directions_walk,
  'commute': Icons.commute,
  // Shopping
  'shopping_bag': Icons.shopping_bag,
  'shopping_cart': Icons.shopping_cart,
  'storefront': Icons.storefront,
  'local_mall': Icons.local_mall,
  'checkroom': Icons.checkroom,
  'redeem': Icons.redeem,
  'card_giftcard': Icons.card_giftcard,
  'loyalty': Icons.loyalty,
  'local_grocery_store': Icons.local_grocery_store,
  'local_offer': Icons.local_offer,
  'sell': Icons.sell,
  // Entertainment
  'movie': Icons.movie,
  'sports_esports': Icons.sports_esports,
  'music_note': Icons.music_note,
  'headphones': Icons.headphones,
  'theater_comedy': Icons.theater_comedy,
  'casino': Icons.casino,
  'sports_soccer': Icons.sports_soccer,
  'sports_basketball': Icons.sports_basketball,
  'fitness_center': Icons.fitness_center,
  'hiking': Icons.hiking,
  'sports_tennis': Icons.sports_tennis,
  'golf_course': Icons.golf_course,
  // Home
  'home': Icons.home,
  'bed': Icons.bed,
  'chair': Icons.chair,
  'bathtub': Icons.bathtub,
  'kitchen': Icons.kitchen,
  'yard': Icons.yard,
  'garage': Icons.garage,
  'local_laundry_service': Icons.local_laundry_service,
  'cleaning_services': Icons.cleaning_services,
  'receipt_long': Icons.receipt_long,
  // Health
  'local_hospital': Icons.local_hospital,
  'medication': Icons.medication,
  'vaccines': Icons.vaccines,
  'health_and_safety': Icons.health_and_safety,
  'spa': Icons.spa,
  'self_improvement': Icons.self_improvement,
  'monitor_heart': Icons.monitor_heart,
  // Education
  'school': Icons.school,
  'menu_book': Icons.menu_book,
  'science': Icons.science,
  'calculate': Icons.calculate,
  'psychology': Icons.psychology,
  'edit': Icons.edit,
  'book': Icons.book,
  'auto_stories': Icons.auto_stories,
  // Finance
  'trending_up': Icons.trending_up,
  'savings': Icons.savings,
  'account_balance': Icons.account_balance,
  'credit_card': Icons.credit_card,
  'payments': Icons.payments,
  'currency_exchange': Icons.currency_exchange,
  'attach_money': Icons.attach_money,
  'money_off': Icons.money_off,
  // Work
  'work': Icons.work,
  'business_center': Icons.business_center,
  'laptop': Icons.laptop,
  'phone_iphone': Icons.phone_iphone,
  'meeting_room': Icons.meeting_room,
  'construction': Icons.construction,
  'laptop_mac': Icons.laptop_mac,
  'phone_android': Icons.phone_android,
  'handyman': Icons.handyman,
  // Other
  'pets': Icons.pets,
  'child_care': Icons.child_care,
  'park': Icons.park,
  'travel_explore': Icons.travel_explore,
  'public': Icons.public,
  'cloud': Icons.cloud,
  'star': Icons.star,
  'favorite': Icons.favorite,
  'volunteer_activism': Icons.volunteer_activism,
  'camera_alt': Icons.camera_alt,
  'brush': Icons.brush,
  'more_horiz': Icons.more_horiz,
};

Color parseCategoryColor(String hex) {
  try {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

IconData categoryIconData(String iconName) =>
    kPickableIcons[iconName] ?? Icons.label;
