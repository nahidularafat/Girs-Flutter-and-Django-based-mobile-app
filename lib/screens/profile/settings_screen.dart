import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../providers/app_providers.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('Account'),
          _ListTile(icon: '👤', title: 'Edit Profile', onTap: () {}),
          _ListTile(icon: '📱', title: 'Change Phone Number', onTap: () {}),
          _SectionHeader(context.l10n.settings),
          Consumer(
            builder: (context, ref, _) {
              final isBangla = ref.watch(localeProvider).languageCode == 'bn';
              return SwitchListTile(
                title: Text(context.l10n.language, style: AppTextStyles.body1),
                subtitle: Text(isBangla ? context.l10n.bangla : context.l10n.english, style: AppTextStyles.caption),
                value: isBangla,
                activeColor: AppColors.primary,
                secondary: const Text('🌐', style: TextStyle(fontSize: 22)),
                onChanged: (val) {
                  ref.read(localeProvider.notifier).state = Locale(val ? 'bn' : 'en');
                },
              );
            }
          ),
          const SizedBox(height: 24),
          _SectionHeader(context.l10n.privacy),
          _ListTile(icon: '📄', title: 'Privacy Policy', onTap: () {}),
          _ListTile(icon: '📋', title: 'Terms of Service', onTap: () {}),
          _ListTile(
            icon: '📤',
            title: context.l10n.dataExport,
            subtitle: 'Download a copy of your health data',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export coming soon!')),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionHeader('Danger Zone'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: _ListTile(
              icon: '🗑️',
              title: context.l10n.deleteAccount,
              subtitle: 'Permanently delete all your data',
              titleColor: AppColors.error,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Account'),
                    content: const Text(
                      'This will permanently delete all your health data, cycle history, and account. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        child: const Text('Delete Everything'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  // TODO: Call DELETE /api/account/delete/
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) context.go('/welcome');
                }
              },
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              'Girls App v1.0.0\nMade with 💕 for women\'s wellness',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  final String icon, title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? titleColor;
  const _ListTile({
    required this.icon, required this.title, required this.onTap,
    this.subtitle, this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: AppTextStyles.body1.copyWith(color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!, style: AppTextStyles.caption) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
