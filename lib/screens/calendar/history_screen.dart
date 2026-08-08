import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../models/cycle_model.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(cycleHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle History')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load history')),
        data: (data) {
          final stats = data['statistics'] as Map<String, dynamic>? ?? {};
          final cycles = (data['cycles'] as List<dynamic>? ?? [])
              .map((c) => CycleLog.fromJson(c))
              .toList();
          final lengths = List<double>.from(
            (stats['cycle_lengths_trend'] as List<dynamic>? ?? []).map((v) => (v as num).toDouble()),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats cards
                if (stats.isNotEmpty) ...[
                  Text('Your Stats', style: AppTextStyles.headline3),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _StatCard(
                        label: 'Avg Cycle', value: '${stats['average_cycle_length']}d', icon: '📊',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'Shortest', value: '${stats['shortest_cycle']}d', icon: '⚡',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        label: 'Longest', value: '${stats['longest_cycle']}d', icon: '🌙',
                      )),
                    ],
                  ),
                ],

                if (lengths.length >= 2) ...[
                  const SizedBox(height: 32),
                  Text('Cycle Length Trend', style: AppTextStyles.headline3),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 5,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: AppColors.primaryLight,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (v, _) => Text(
                                '${v.round()}d',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Text(
                                'C${v.round() + 1}',
                                style: AppTextStyles.caption,
                              ),
                            ),
                          ),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: lengths.asMap().entries.map((e) =>
                              FlSpot(e.key.toDouble(), e.value)).toList(),
                            isCurved: true,
                            gradient: AppColors.primaryGradient,
                            barWidth: 3,
                            dotData: FlDotData(
                              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                                radius: 5,
                                color: AppColors.primary,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primary.withOpacity(0.2),
                                  AppColors.primary.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ],
                        minY: 21,
                        maxY: 35,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),
                Text('All Cycles', style: AppTextStyles.headline3),
                const SizedBox(height: 16),

                if (cycles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No cycles logged yet', style: AppTextStyles.subtitle2),
                        Text('Start logging to see your history here', style: AppTextStyles.caption),
                      ],
                    ),
                  )
                else
                  ...cycles.map((cycle) => _CycleCard(cycle: cycle)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, icon;
  const _StatCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.headline3.copyWith(color: AppColors.primary)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  final CycleLog cycle;
  const _CycleCard({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Center(child: Text('🌸', style: TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cycle.startDate, style: AppTextStyles.subtitle1),
                if (cycle.duration != null)
                  Text('${cycle.duration} days', style: AppTextStyles.caption),
              ],
            ),
          ),
          if (cycle.flowIntensity != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(cycle.flowIntensity!, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)),
            ),
        ],
      ),
    );
  }
}
