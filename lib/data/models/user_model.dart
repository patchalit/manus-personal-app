class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  // Convert from Map (SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['display_name'] as String?,
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
      'email': email,
      'display_name': displayName,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
    };
  }

  // Convert from Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      updatedAt: (data['updatedAt'] as dynamic).toDate(),
      syncedAt: null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
