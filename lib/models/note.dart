class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? reminderDate;
  final bool isCompleted;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.reminderDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      reminderDate: map['reminderDate'] != null
          ? DateTime.parse(map['reminderDate'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  Note copyWith({
    String? title,
    String? content,
    DateTime? reminderDate,
    bool? isCompleted,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      reminderDate: reminderDate ?? this.reminderDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
