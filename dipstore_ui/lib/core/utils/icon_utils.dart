import 'package:flutter/material.dart';

IconData getBusinessIcon(String category) {
  switch (category.toLowerCase()) {
    case 'fashion':
      return Icons.checkroom_rounded;
    case 'electronics':
      return Icons.devices_rounded;
    case 'sportswear':
      return Icons.sports_basketball_rounded;
    case 'furniture':
      return Icons.chair_rounded;
    case 'cosmetics':
      return Icons.auto_fix_high_rounded;
    case 'education':
      return Icons.menu_book_rounded;
    default:
      return Icons.storefront_rounded;
  }
}
