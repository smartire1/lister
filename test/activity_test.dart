import 'package:flutter_test/flutter_test.dart';
import 'package:lister/models/activity.dart';

void main() {
  test('Activity mantiene i dati dopo la conversione JSON', () {
    final activity = Activity(
      title: 'Provare Lister',
      isCompleted: true,
      isImportant: true,
    );

    final restored = Activity.fromJson(activity.toJson());

    expect(restored.id, activity.id);
    expect(restored.title, activity.title);
    expect(restored.isCompleted, isTrue);
    expect(restored.isImportant, isTrue);
  });
}
