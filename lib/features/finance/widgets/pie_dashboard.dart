import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:ti3h_k1_jawara/core/themes/app_colors.dart';

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: AppColors.textPrimary(context))),
      ],
    );
  }
}

class FilterTime extends StatefulWidget {
  final bool isDark;
  final Function(String period) onPeriodChanged;
  final int initialIndex;

  const FilterTime({
    super.key, 
    required this.isDark,
    required this.onPeriodChanged,
    this.initialIndex = 3,
  });

  @override
  State<FilterTime> createState() => _FilterTimeState();
}

class _FilterTimeState extends State<FilterTime> {
  late int selectedIndex;
  final List<String> labels = ["H", "B", "T", "∞"];
  final List<String> periods = ["day", "month", "year", "all"];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (index) {
        return Row(
          children: [
            InkWell(
              onTap: () {
                setState(() => selectedIndex = index);
                widget.onPeriodChanged(periods[index]);
              },
              borderRadius: BorderRadius.circular(20),
              child: _circle(context, labels[index], index == selectedIndex),
            ),
            const SizedBox(width: 8),
          ],
        );
      }),
    );
  }

  Widget _circle(BuildContext context, String label, bool selected) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: selected
          ? AppColors.primary(context)
          : (widget.isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : AppColors.textPrimary(context),
        ),
      ),
    );
  }
}

class PieDashboard extends StatelessWidget {
  final bool isDark;
  final double income;
  final double expense;
  final bool isLoading;

  const PieDashboard({
    super.key,
    required this.isDark,
    required this.income,
    required this.expense,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData( 
          startDegreeOffset: 0,
          centerSpaceRadius: 0,
          sectionsSpace: 4,
          sections: [
            PieChartSectionData(
              title: "${income.toStringAsFixed(1)}%",
              value: income,
              color: AppColors.primary(context),
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              titlePositionPercentageOffset: 0.55,
            ),
            PieChartSectionData(
              title: "${expense.toStringAsFixed(1)}%",
              value: expense,
              color: AppColors.redAccent(context),
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              titlePositionPercentageOffset: 0.55,
            ),
          ],
        ),
      ),
    );
  }
}
