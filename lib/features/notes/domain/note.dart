enum NoteCategory { ideas, work, personal, study, general }

extension NoteCategoryX on NoteCategory {
  String get key => switch (this) {
        NoteCategory.ideas => 'ideas',
        NoteCategory.work => 'work',
        NoteCategory.personal => 'personal',
        NoteCategory.study => 'study',
        NoteCategory.general => 'general',
      };

  String get label => switch (this) {
        NoteCategory.ideas => 'ایده‌ها',
        NoteCategory.work => 'کار',
        NoteCategory.personal => 'شخصی',
        NoteCategory.study => 'مطالعه',
        NoteCategory.general => 'عمومی',
      };

  static NoteCategory fromKey(String value) => switch (value) {
        'ideas' => NoteCategory.ideas,
        'work' => NoteCategory.work,
        'personal' => NoteCategory.personal,
        'study' => NoteCategory.study,
        _ => NoteCategory.general,
      };
}

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.isPinned,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String content;
  final NoteCategory category;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    bool? isPinned,
    bool? isArchived,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
