import 'dart:convert';

enum RichBlockType {
  text,
  heading,
  checklist,
  bulletList,
  numberedList,
  quote,
  code,
  date,
  divider,
  toggle,
  image,
  video,
  audio,
  file,
}

class RichBlock {
  const RichBlock({
    required this.id,
    required this.type,
    this.text = '',
    this.mediaId,
    this.checked = false,
    this.expanded = true,
  });

  final String id;
  final RichBlockType type;
  final String text;
  final String? mediaId;
  final bool checked;
  final bool expanded;

  RichBlock copyWith({
    RichBlockType? type,
    String? text,
    String? mediaId,
    bool? checked,
    bool? expanded,
  }) {
    return RichBlock(
      id: id,
      type: type ?? this.type,
      text: text ?? this.text,
      mediaId: mediaId ?? this.mediaId,
      checked: checked ?? this.checked,
      expanded: expanded ?? this.expanded,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'text': text,
    'mediaId': mediaId,
    'checked': checked,
    'expanded': expanded,
  };

  factory RichBlock.fromJson(Map<String, dynamic> json) => RichBlock(
    id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
    type: RichBlockType.values.firstWhere(
      (v) => v.name == json['type'],
      orElse: () => RichBlockType.text,
    ),
    text: json['text']?.toString() ?? '',
    mediaId: json['mediaId']?.toString(),
    checked: json['checked'] == true,
    expanded: json['expanded'] != false,
  );
}

class RichDocument {
  const RichDocument(this.blocks);

  final List<RichBlock> blocks;

  String encode() => jsonEncode({
    'version': 1,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  });

  static RichDocument decode(String value) {
    try {
      final raw = jsonDecode(value);
      if (raw is Map && raw['blocks'] is List) {
        return RichDocument(
          (raw['blocks'] as List)
              .whereType<Map>()
              .map((e) => RichBlock.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
      }
    } catch (_) {}
    return RichDocument([
      RichBlock(id: 'legacy', type: RichBlockType.text, text: value),
    ]);
  }

  String get plainText => blocks
      .where((b) => b.type != RichBlockType.divider)
      .map((b) => b.text)
      .where((v) => v.isNotEmpty)
      .join('\n');
}
