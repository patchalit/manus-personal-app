import 'dart:convert';

class KnowledgeEntryModel {
  final String id;
  final String projectId;
  final String title;
  final String content;
  final String? category; // 'insight', 'rule', 'pattern', 'preference', 'other'
  final List<String> tags;
  final String? sourceMessageId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  KnowledgeEntryModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.content,
    this.category,
    required this.tags,
    this.sourceMessageId,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  // Convert from Map (SQLite)
  factory KnowledgeEntryModel.fromMap(Map<String, dynamic> map) {
    return KnowledgeEntryModel(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String?,
      tags: map['tags'] != null
          ? List<String>.from(jsonDecode(map['tags'] as String))
          : [],
      sourceMessageId: map['source_message_id'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int)
          : null,
    );
  }

  // Convert to Map (SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'content': content,
      'category': category,
      'tags': jsonEncode(tags),
      'source_message_id': sourceMessageId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
    };
  }

  // Convert from Firestore
  factory KnowledgeEntryModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return KnowledgeEntryModel(
      id: id,
      projectId: data['projectId'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      category: data['category'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      sourceMessageId: data['sourceMessageId'] as String?,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      updatedAt: (data['updatedAt'] as dynamic).toDate(),
      syncedAt: null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'sourceMessageId': sourceMessageId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  KnowledgeEntryModel copyWith({
    String? id,
    String? projectId,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    String? sourceMessageId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return KnowledgeEntryModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
