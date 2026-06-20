import 'package:flutter/material.dart';
import '../../config/app_styles.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';
import '../../widgets/common_widgets.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  String _category = 'inne';
  DateTime _date = DateTime.now();
  CityLocation _location = cityLocations.first;
  List<dynamic> _friends = [];
  List<String> _selectedIds = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final friends = await FriendService.getFriends();
    setState(() => _friends = friends);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wybierz co najmniej jednego uczestnika')));
      return;
    }
    setState(() => _loading = true);
    final res = await EventService.createEvent(
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      date: _date,
      participantIds: _selectedIds,
      locationName: _location.name,
      latitude: _location.latitude,
      longitude: _location.longitude,
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['success'] == true) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Błąd')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nowe wydarzenie')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nazwa wydarzenia',
                        prefixIcon: Icon(Icons.event_outlined),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Podaj nazwę' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Kwota (zł)',
                        prefixIcon: Icon(Icons.payments_outlined),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Podaj kwotę';
                        if (double.tryParse(v) == null) return 'Nieprawidłowa kwota';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Kategoria'),
                      items: categoryEmoji.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text('${e.value} ${e.key}')))
                          .toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CityLocation>(
                      value: _location,
                      decoration: const InputDecoration(
                        labelText: 'Lokalizacja',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      items: cityLocations.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: (v) => setState(() => _location = v!),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                      title: const Text('Data wydarzenia'),
                      subtitle: Text('${_date.day}.${_date.month}.${_date.year}'),
                      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                      onTap: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (d != null) setState(() => _date = d);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(title: 'Uczestnicy (${_selectedIds.length})'),
              const SizedBox(height: 10),
              if (_friends.isEmpty)
                const AppCard(
                  child: EmptyState(
                    icon: Icons.people_outline,
                    title: 'Brak znajomych',
                    subtitle: 'Dodaj znajomych przed utworzeniem wydarzenia',
                  ),
                )
              else
                ..._friends.map((f) {
                  final id = f['_id'];
                  final name = f['name'] ?? '';
                  final selected = _selectedIds.contains(id);
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 8),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedIds.remove(id);
                        } else {
                          _selectedIds.add(id);
                        }
                      });
                    },
                    color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
                    child: Row(
                      children: [
                        UserAvatar(name: name, color: selected ? AppColors.primary : AppColors.textSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(f['email'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                        Icon(
                          selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                          color: selected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ElevatedButton(onPressed: _submit, child: const Text('Utwórz wydarzenie')),
            ],
          ),
        ),
      ),
    );
  }
}
