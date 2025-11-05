class MessageModel {
  final String id;
  final String projectId;
  final String sender; // 'user' or 'manus'
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  MessageModel({
    required this.id,
    required this.projectId,
    required this.sender,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  bool get isFromUser => sender == 'user';
  bool get isFromManus => sender == 'manus';

  // Convert from Map (SQLite)
  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      sender: map['sender'] as String,
      content: map['content'] as String,
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
      'sender': sender,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
    };
  }

  // Convert from Firestore
  factory MessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      projectId: data['projectId'] as String,
      sender: data['sender'] as String,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      updatedAt: (data['updatedAt'] as dynamic).toDate(),
      syncedAt: null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'sender': sender,
      'content': content,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  MessageModel copyWith({
    String? id,
    String? projectId,
    String? sender,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
