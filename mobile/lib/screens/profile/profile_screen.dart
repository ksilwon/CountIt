import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
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
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          Hero(
            tag: 'profile_avatar',
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: _editing ? 90 : 100,
              height: _editing ? 90 : 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: !_editing
                ? Column(
                    key: const ValueKey('view'),
                    children: [
                      Text(user?.name ?? '', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 24),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.edit_outlined, color: primary),
                              title: const Text('Edytuj profil'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => setState(() => _editing = true),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    key: const ValueKey('edit'),
                    children: [
                      TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(labelText: 'Imię'),
                      ),
                      const SizedBox(height: 16),
                      auth.isLoading
                          ? const CircularProgressIndicator()
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
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => setState(() => _editing = false),
                                    child: const Text('Anuluj'),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
          ),
          const SizedBox(height: 32),
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
            icon: const Icon(Icons.logout, color: Colors.red),
            label: const Text('Wyloguj', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: Colors.red.shade200),
            ),
          ),
        ],
      ),
    );
  }
}
