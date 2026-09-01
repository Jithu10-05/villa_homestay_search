import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../domain/models/property_sort.dart';

/// Horizontal row of sort options above the results list.
class SortBar extends StatelessWidget {
  const SortBar({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final PropertySort selected;
  final ValueChanged<PropertySort> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: PropertySort.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) {
          final PropertySort sort = PropertySort.values[index];
          final bool isSelected = sort == selected;

          return ChoiceChip(
            label: Text(sort.label),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(sort),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.ink,
            ),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          );
        },
      ),
    );
  }
}
