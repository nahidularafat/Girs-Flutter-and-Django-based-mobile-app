import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/cycle_ring_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final predictionAsync = ref.watch(predictionProvider);
    final guidanceAsync = ref.watch(guidanceProvider);
    final profile = ref.watch(profileProvider);

    final userName = profile.value?.mobileNumber.replaceAll('+88', '') ?? '';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            snap: true,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.today, style: AppTextStyles.caption),
                    Text(
                      DateFormat('MMMM d').format(DateTime.now()),
                      style: AppTextStyles.subtitle1,
                    ),
                  ],
                ),
                const Spacer(),
                const Text('🌸', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Cycle Ring section
                  predictionAsync.when(
                    loading: () => _CycleRingSkeleton(),
                    error: (_, __) => _ErrorCard(),
                    data: (prediction) {
                      if (prediction == null) return _NoCycleCard(ref: ref);
                      return Column(
                        children: [
                          // Greeting
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: AppColors.phaseGradient(prediction.currentPhase),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              children: [
                                CycleRingWidget(
                                  currentDay: prediction.currentCycleDay,
                                  totalDays: prediction.avgCycleLength,
                                  phase: prediction.currentPhase,
                                  daysUntilPeriod: prediction.daysUntilNextPeriod,
                                ),
                                const SizedBox(height: 24),
                                // Info pills
                                Row(
                                  children: [
                                    Expanded(child: _InfoPill(
                                      label: context.l10n.nextPeriod,
                                      value: DateFormat('MMM d').format(
                                        DateTime.parse(prediction.nextPeriodDate),
                                      ),
                                      icon: '🩸',
                                    )),
                                    const SizedBox(width: 12),
                                    Expanded(child: _InfoPill(
                                      label: context.l10n.fertileWindow,
                                      value: '${DateFormat('MMM d').format(DateTime.parse(prediction.fertileWindowStart))} – ${DateFormat('d').format(DateTime.parse(prediction.fertileWindowEnd))}',
                                      icon: '🌿',
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Quick log button
                          GestureDetector(
                            onTap: () => context.push('/log-symptoms'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Text('✏️', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(context.l10n.logToday, style: AppTextStyles.subtitle1),
                                      Text(context.l10n.flowSymptomsNotes, style: AppTextStyles.caption),
                                    ],
                                  ),
                                  const Spacer(),
                                  Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // AI Guidance Card
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(context.l10n.todayGuidance, style: AppTextStyles.headline3),
                  ),
                  const SizedBox(height: 12),
                  guidanceAsync.when(
                    loading: () => _GuidanceSkeleton(),
                    error: (_, __) => const SizedBox(),
                    data: (guidance) {
                      if (guidance == null) return const SizedBox();
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(guidance.guidanceTitle, style: AppTextStyles.subtitle1),
                            const SizedBox(height: 12),
                            Text(
                              guidance.guidanceContent,
                              style: AppTextStyles.body2.copyWith(height: 1.7),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Text('⚕️', style: TextStyle(fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      context.l10n.disclaimer,
                                      style: AppTextStyles.caption,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label, value, icon;
  const _InfoPill({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        // Darker background for better contrast against gradient
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.phaseLabel.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCycleCard extends StatelessWidget {
  final WidgetRef ref;
  const _NoCycleCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          const Text('🌸', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(context.l10n.welcome, style: AppTextStyles.headline2.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            context.l10n.logFirstPeriod,
            textAlign: TextAlign.center,
            style: AppTextStyles.body2.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.push('/log-symptoms'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
            ),
            child: Text(context.l10n.logFirstPeriodBtn),
          ),
        ],
      ),
    );
  }
}

class _CycleRingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(28),
      ),
    );
  }
}

class _GuidanceSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('Could not load data. Make sure the backend is running.', style: AppTextStyles.body2),
    );
  }
}
