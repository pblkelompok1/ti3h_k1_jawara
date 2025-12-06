import 'package:flutter/material.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class FilterChipGroup extends StatelessWidget {
  final List<String> labels;
  final int? selectedIndex;
  final Function(int) onSelected;
  final bool scrollable;

  const FilterChipGroup({
    super.key,
    required this.labels,
    this.selectedIndex,
    required this.onSelected,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(labels.length, (index) {
        final isSelected = selectedIndex == index;
        return FilterChip(
          label: Text(labels[index]),
          selected: isSelected,
          onSelected: (selected) => onSelected(index),
          backgroundColor: AppColors.bgPrimaryInputBox(context),
          selectedColor: AppColors.primary(context).withOpacity(0.2),
          checkmarkColor: AppColors.primary(context),
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.primary(context)
                : AppColors.textSecondary(context),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary(context)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
        );
      }),
    );

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: widget,
      );
    }

    return widget;
  }
}
