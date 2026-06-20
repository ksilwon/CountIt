import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_palette.dart';
import '../../config/app_styles.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/theme_selector.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.user?.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final palette = context.palette;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          AppCard(
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  width: _editing ? 80 : 96,
                  height: _editing ? 80 : 96,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.card,
                  ),
                  child: Center(
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: _editing ? 32 : 38,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: !_editing
                      ? Column(
                          key: const ValueKey('view'),
                          children: [
                            Text(
                              user?.name ?? '',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(user?.email ?? '', style: TextStyle(color: context.palette.textSecondary)),
                          ],
                        )
                      : Column(
                          key: const ValueKey('edit'),
                          children: [
                            TextField(
                              controller: _nameCtrl,
                              decoration: const InputDecoration(labelText: 'Imię'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: !_editing
                ? AppCard(
                    key: const ValueKey('actions-view'),
                    onTap: () => setState(() => _editing = true),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Edytuj profil',
                            style: TextStyle(fontWeight: FontWeight.w600, color: palette.textPrimary),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: palette.textMuted),
                      ],
                    ),
                  )
                : AppCard(
                    key: const ValueKey('actions-edit'),
                    child: auth.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final ok = await auth.updateProfile(_nameCtrl.text.trim());
                                    if (ok && mounted) setState(() => _editing = false);
                                  },
                                  child: const Text('Zapisz'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _editing = false),
                                  child: const Text('Anuluj'),
                                ),
                              ),
                            ],
                          ),
                  ),
          ),
          const SizedBox(height: 16),
          const ThemeSelector(),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text('Wyloguj', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.55)),
              backgroundColor: palette.dangerSoft,
              foregroundColor: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
