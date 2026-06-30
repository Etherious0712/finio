import 'package:flutter/material.dart';

import 'package:finio/app_localizations.dart';
import 'package:finio/core/database/app_database.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_spacing.dart';
import '../utils/category_icon.dart';
import '../utils/category_localizer.dart';

/// A grid of selectable category cells, reused by the add/edit screen and the
/// quick-add sheet. Selection is highlighted with the category's own color.
class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
    this.crossAxisCount = 4,
  });

  final List<Category> categories;
  final String? selected;
  final ValueChanged<String> onSelect;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.82,
      children: [
        for (final c in categories)
          _CategoryCell(
            category: c,
            selected: c.name == selected,
            onTap: () => onSelect(c.name),
          ),
      ],
    );
  }
}

class _CategoryCell extends StatelessWidget {
  const _CategoryCell({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final catColor = parseCategoryColor(category.color);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Motion.fast,
        curve: Motion.curve,
        margin: const EdgeInsets.all(Insets.xs),
        decoration: BoxDecoration(
          color: selected ? catColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(
            color: selected ? catColor : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(Insets.sm),
              decoration: BoxDecoration(
                color: selected ? catColor : catColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                categoryIconData(category.icon),
                size: 20,
                color: selected ? Colors.white : catColor,
              ),
            ),
            const SizedBox(height: Insets.xs),
            Text(
              localizeCategory(AppLocalizations.of(context)!, category.name),
              style: TextStyle(
                fontSize: 11,
                color: selected ? catColor : scheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
