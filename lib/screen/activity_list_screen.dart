import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lister/models/activity.dart';
import 'package:lister/screen/add_activity_screen.dart';
import 'package:lister/services/activity_storage.dart';

class ActivityListScreen extends StatefulWidget {
  const ActivityListScreen({super.key});

  @override
  State<ActivityListScreen> createState() => _ActivityListScreenState();
}

class _ActivityListScreenState extends State<ActivityListScreen> {
  final _storage = ActivityStorage();
  List<Activity> _activities = [];
  bool _isLoading = true;

  int get _completedCount =>
      _activities.where((activity) => activity.isCompleted).length;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    final activities = await _storage.load();
    if (!mounted) return;

    setState(() {
      _activities = activities;
      _isLoading = false;
    });
  }

  Future<void> _saveActivities() => _storage.save(_activities);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lister')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Completate: $_completedCount/${_activities.length}',
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final activity in _activities)
                        _buildActivityTile(activity),
                      Center(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                          onPressed: _openAddActivityScreen,
                          icon: const Icon(Icons.add),
                          label: const Text('Aggiungi attività'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    return ListTile(
      key: ValueKey(activity.id),
      leading: IconButton(
        onPressed: () => _updateImportance(activity),
        icon: Icon(
          activity.isImportant ? Icons.star : Icons.star_border,
          color: activity.isImportant ? Colors.amber : null,
        ),
        tooltip: activity.isImportant
            ? 'Rimuovi importanza'
            : 'Segna come importante',
      ),
      title: Text(
        activity.title,
        style: TextStyle(
          decoration: activity.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(activity.isCompleted ? 'Completata' : 'Da fare'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: activity.isCompleted,
            activeTrackColor: Colors.green,
            onChanged: (value) => _updateStatus(activity, value),
          ),
          IconButton(
            onPressed: () => _confirmDelete(activity),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Elimina',
          ),
        ],
      ),
    );
  }

  Future<void> _openAddActivityScreen() async {
    final newActivity = await Navigator.push<Activity>(
      context,
      MaterialPageRoute(builder: (context) => const AddActivityScreen()),
    );

    if (!mounted || newActivity == null) return;

    setState(() => _activities.add(newActivity));
    await _saveActivities();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Attività aggiunta')));
  }

  Future<void> _updateStatus(Activity activity, bool value) async {
    setState(() => activity.isCompleted = value);
    await _saveActivities();
  }

  Future<void> _updateImportance(Activity activity) async {
    setState(() => activity.isImportant = !activity.isImportant);
    await _saveActivities();
  }

  Future<void> _confirmDelete(Activity activity) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black26,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: AlertDialog(
          title: const Text('Eliminare l’attività?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sei sicuro di voler eliminare “${activity.title}”?'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Elimina'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annulla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _activities.removeWhere((item) => item.id == activity.id));
    await _saveActivities();
  }
}
