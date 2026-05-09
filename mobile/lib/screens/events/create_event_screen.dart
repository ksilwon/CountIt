import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/constants.dart';

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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Nazwa wydarzenia', prefixIcon: Icon(Icons.event)),
                validator: (v) => v == null || v.isEmpty ? 'Podaj nazwę' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountCtrl,
                decoration: const InputDecoration(labelText: 'Kwota (PLN)', prefixIcon: Icon(Icons.attach_money)),
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
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text('Data: ${_date.day}.${_date.month}.${_date.year}'),
                onTap: () async {
                  final d = await showDatePicker(
                      context: context, initialDate: _date, firstDate: DateTime(2020), lastDate: DateTime(2030));
                  if (d != null) setState(() => _date = d);
                },
                contentPadding: EdgeInsets.zero,
              ),
              const Divider(),
              Text('Uczestnicy (${_selectedIds.length} wybrano)',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_friends.isEmpty)
                const Text('Brak znajomych. Dodaj znajomych najpierw.', style: TextStyle(color: Colors.grey))
              else
                ..._friends.map((f) {
                  final id = f['_id'];
                  final name = f['name'] ?? '';
                  return CheckboxListTile(
                    value: _selectedIds.contains(id),
                    title: Text(name),
                    subtitle: Text(f['email'] ?? ''),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) _selectedIds.add(id);
                        else _selectedIds.remove(id);
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                }),
              const SizedBox(height: 24),
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _submit, child: const Text('Utwórz wydarzenie')),
            ],
          ),
        ),
      ),
    );
  }
}
