class Activity {
  final String id;
  final String title;
  bool isCompleted;
  bool isImportant;

  Activity({
    String? id,
    required this.title,
    this.isCompleted = false,
    this.isImportant = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'isImportant': isImportant,
  };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String?,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isImportant: json['isImportant'] as bool? ?? false,
    );
  }
}
