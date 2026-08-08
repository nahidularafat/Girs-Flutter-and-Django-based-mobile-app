import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../services/notification_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Could not load profile')),
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🌸', style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 16),
              if (profile != null) ...[
                Text(profile.mobileNumber, style: AppTextStyles.headline3),
                const SizedBox(height: 4),
                Text('Age ${profile.age} · ${profile.maritalStatus}', style: AppTextStyles.body2),
              ],
              const SizedBox(height: 32),

              // Settings rows
              _SettingsSection(title: 'Cycle Preferences', items: [
                if (profile != null) ...[
                  _SettingsRow(icon: '📅', title: 'Avg Cycle Length', value: '${profile.avgCycleLength} days'),
                  _SettingsRow(icon: '🩸', title: 'Period Duration', value: '${profile.avgPeriodDuration} days'),
                ],
              ]),
              const SizedBox(height: 20),
              _SettingsSection(title: 'Notifications', items: [
                _SettingsRow(
                  icon: '🔔',
                  title: 'Reminders',
                  value: profile?.notificationsEnabled == true ? 'On' : 'Off',
                ),
                _SettingsRow(
                  icon: '🧪',
                  title: 'Test Notification',
                  trailing: TextButton(
                    onPressed: () async {
                      await NotificationService().requestPermissions();
                      await NotificationService().showInstantTestNotification();
                    },
                    child: const Text('Test'),
                  ),
                ),
              ]),
              const SizedBox(height: 20),
              _SettingsSection(title: 'Appearance & Language', items: [
                Consumer(builder: (context, ref, _) {
                  final isDark = ref.watch(themeModeProvider);
                  return _SettingsRow(
                    icon: isDark ? '🌙' : '☀️',
                    title: 'Dark Mode',
                    trailing: Switch(
                      value: isDark,
                      onChanged: (v) => ref.read(themeModeProvider.notifier).state = v,
                      activeColor: AppColors.primary,
                    ),
                  );
                }),
                Consumer(builder: (context, ref, _) {
                  final isBangla = ref.watch(localeProvider).languageCode == 'bn';
                  return _SettingsRow(
                    icon: '🌐',
                    title: 'বাংলা ভাষা',
                    trailing: Switch(
                      value: isBangla,
                      onChanged: (v) => ref.read(localeProvider.notifier).state = Locale(v ? 'bn' : 'en'),
                      activeColor: AppColors.primary,
                    ),
                  );
                }),
              ]),
              const SizedBox(height: 40),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Sign Out'),
                      content: const Text('Are you sure you want to sign out?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sign Out')),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await ref.read(authProvider.notifier).signOut();
                    context.go('/welcome');
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.caption.copyWith(
          color: AppColors.primary, fontWeight: FontWeight.w600, letterSpacing: 1.5,
        )),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String icon, title;
  final String? value;
  final Widget? trailing;
  const _SettingsRow({required this.icon, required this.title, this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: AppTextStyles.body1)),
          if (trailing != null) trailing!
          else if (value != null) Text(value!, style: AppTextStyles.body2),
        ],
      ),
    );
  }
}
