import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../models/cycle_model.dart';
import '../../l10n/app_localizations.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(predictionProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendar)),
      // Wrap body in SingleChildScrollView to prevent overflow with 6-week months
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: predictionAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Center(child: Text(l10n.couldNotLoad)),
          data: (prediction) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SimpleCalendarGrid(prediction: prediction),
                const SizedBox(height: 28),
                Text(l10n.cycleLegend, style: AppTextStyles.subtitle1),
                const SizedBox(height: 12),
                _LegendRow(color: const Color(0xFFF06292), label: l10n.periodDays),
                const SizedBox(height: 8),
                _LegendRow(
                  color: const Color(0xFFF06292).withOpacity(0.4),
                  label: '${l10n.predictedPeriod} (±${prediction?.confidenceDays ?? 3} ${l10n.days})',
                ),
                const SizedBox(height: 8),
                _LegendRow(color: const Color(0xFF4FB3BF), label: l10n.fertileWindowLegend),
                const SizedBox(height: 8),
                _LegendRow(color: const Color(0xFF66BB6A), label: l10n.ovulationLegend),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SimpleCalendarGrid extends StatelessWidget {
  final PredictionData? prediction;
  const _SimpleCalendarGrid({this.prediction});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);
    final weekdayOffset = firstDay.weekday % 7; // 0=Sun

    Set<String> periodDays = {};
    Set<String> predictedDays = {};
    Set<String> fertileDays = {};
    String? ovulationDay;

    if (prediction != null) {
      final lastPeriod = DateTime.parse(prediction!.lastPeriodDate);
      for (int i = 0; i < 5; i++) {
        periodDays.add(DateFormat('yyyy-MM-dd').format(lastPeriod.add(Duration(days: i))));
      }
      final nextPeriod = DateTime.parse(prediction!.nextPeriodDate);
      for (int i = -prediction!.confidenceDays; i <= prediction!.confidenceDays + 5; i++) {
        predictedDays.add(DateFormat('yyyy-MM-dd').format(nextPeriod.add(Duration(days: i))));
      }
      final fertileStart = DateTime.parse(prediction!.fertileWindowStart);
      final fertileEnd = DateTime.parse(prediction!.fertileWindowEnd);
      for (DateTime d = fertileStart;
          d.isBefore(fertileEnd.add(const Duration(days: 1)));
          d = d.add(const Duration(days: 1))) {
        fertileDays.add(DateFormat('yyyy-MM-dd').format(d));
      }
      ovulationDay = prediction!.ovulationDate;
    }

    final totalCells = weekdayOffset + lastDay.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('MMMM yyyy').format(now), style: AppTextStyles.headline3),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
          ],
        ),
        const SizedBox(height: 12),
        // Weekday headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Days grid — shrinkWrap so it sizes to content, no fixed height
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.9, // slightly taller cells to fit 6 rows
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
          ),
          itemCount: totalCells,
          itemBuilder: (_, index) {
            if (index < weekdayOffset) return const SizedBox();
            final day = index - weekdayOffset + 1;
            final date = DateTime(now.year, now.month, day);
            final dateStr = DateFormat('yyyy-MM-dd').format(date);
            final isToday = day == now.day;

            Color? bgColor;
            bool isStrongBg = false;
            if (periodDays.contains(dateStr)) {
              bgColor = const Color(0xFFF06292);
              isStrongBg = true;
            } else if (dateStr == ovulationDay) {
              bgColor = const Color(0xFF66BB6A);
              isStrongBg = true;
            } else if (fertileDays.contains(dateStr)) {
              bgColor = const Color(0xFF4FB3BF);
              isStrongBg = true; // High contrast for teal
            } else if (predictedDays.contains(dateStr)) {
              bgColor = const Color(0xFFF06292).withOpacity(0.4);
              isStrongBg = false;
            }

            final isDark = Theme.of(context).brightness == Brightness.dark;
            final nonEventTextColor = isDark ? const Color(0xFFB8B5C4) : AppColors.textPrimary;
            final textColor = isStrongBg
                ? Colors.white
                : (isToday ? AppColors.primary : nonEventTextColor);

            return Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.primary, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color, 
            shape: BoxShape.circle,
            // Add subtle border if color is highly transparent (like predicted)
            border: color.opacity < 1.0 ? Border.all(color: color.withOpacity(1.0), width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label, 
          style: AppTextStyles.body2.copyWith(
            color: isDark ? const Color(0xFFE0DFE5) : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
