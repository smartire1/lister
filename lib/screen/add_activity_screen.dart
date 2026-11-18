import 'package:flutter/material.dart';
import 'package:lister/models/activity.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  bool _isImportant = false;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final activity = Activity(
      title: _titleController.text.trim(),
      isImportant: _isImportant,
    );

    Navigator.pop(context, activity);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuova attività')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Titolo',
                  border: OutlineInputBorder(),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Inserisci il titolo dell’attività';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Attività importante'),
                value: _isImportant,
                onChanged: (value) => setState(() => _isImportant = value),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _submit, child: const Text('Salva')),
            ],
          ),
        ),
      ),
    );
  }
}
