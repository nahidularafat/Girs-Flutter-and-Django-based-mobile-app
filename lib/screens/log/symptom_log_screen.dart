import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../services/api_service.dart';
import '../../widgets/primary_button.dart';

class SymptomLogScreen extends ConsumerStatefulWidget {
  const SymptomLogScreen({super.key});
  @override
  ConsumerState<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends ConsumerState<SymptomLogScreen> {
  String? _flowIntensity;
  final Set<String> _selectedSymptoms = {};
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isPeriodStart = false;

  final List<_SymptomOption> _symptoms = [
    _SymptomOption('cramps', 'Cramps', '😣'),
    _SymptomOption('headache', 'Headache', '🤕'),
    _SymptomOption('bloating', 'Bloating', '🎈'),
    _SymptomOption('mood_swings', 'Mood Swings', '😤'),
    _SymptomOption('fatigue', 'Fatigue', '😴'),
    _SymptomOption('nausea', 'Nausea', '🤢'),
    _SymptomOption('breast_tenderness', 'Breast Tenderness', '💗'),
    _SymptomOption('acne', 'Acne', '😬'),
    _SymptomOption('back_pain', 'Back Pain', '🔙'),
    _SymptomOption('cravings', 'Cravings', '🍫'),
    _SymptomOption('insomnia', 'Insomnia', '🌙'),
    _SymptomOption('spotting', 'Spotting', '🩸'),
  ];

  Future<void> _save() async {
    setState(() => _isLoading = true);
    final api = ApiService();
    try {
      // If marking period start, create a new cycle
      if (_isPeriodStart || _flowIntensity != null) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        await api.logCycle({
          'start_date': today,
          'flow_intensity': _flowIntensity,
          'notes': _notesController.text,
        });
      }
      // Refresh data
      ref.invalidate(predictionProvider);
      ref.invalidate(guidanceProvider);
      ref.invalidate(cyclesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Logged successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Today'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: AppTextStyles.subtitle2),
            const SizedBox(height: 24),

            // Period start toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isPeriodStart ? AppColors.primaryLight : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isPeriodStart ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Text('🩸', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Period started today', style: AppTextStyles.subtitle1),
                      Text('Log a new cycle', style: AppTextStyles.caption),
                    ],
                  )),
                  Switch(
                    value: _isPeriodStart,
                    onChanged: (v) => setState(() => _isPeriodStart = v),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),

            if (_isPeriodStart) ...[
              const SizedBox(height: 24),
              Text('Flow Intensity', style: AppTextStyles.subtitle1),
              const SizedBox(height: 12),
              Row(
                children: ['light', 'medium', 'heavy'].map((f) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _flowIntensity = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _flowIntensity == f ? AppColors.primary : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            Text(
                              f == 'light' ? '💧' : f == 'medium' ? '💦' : '🌊',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              f[0].toUpperCase() + f.substring(1),
                              style: AppTextStyles.caption.copyWith(
                                color: _flowIntensity == f ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )).toList(),
              ),
            ],

            const SizedBox(height: 24),
            Text('Symptoms', style: AppTextStyles.subtitle1),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptoms.map((s) {
                final selected = _selectedSymptoms.contains(s.value);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) _selectedSymptoms.remove(s.value);
                    else _selectedSymptoms.add(s.value);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(s.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          s.label,
                          style: AppTextStyles.caption.copyWith(
                            color: selected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            Text('Notes', style: AppTextStyles.subtitle1),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'How are you feeling today?'),
            ),

            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Save Log',
              onPressed: _isLoading ? null : _save,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SymptomOption {
  final String value, label, emoji;
  _SymptomOption(this.value, this.label, this.emoji);
}
