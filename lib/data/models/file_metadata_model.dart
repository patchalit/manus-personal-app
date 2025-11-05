class FileMetadataModel {
  final String id;
  final String projectId;
  final String? messageId;
  final String originalFilename;
  final int fileSize;
  final String mimeType;
  final String? localPath;
  final String? cloudUrl;
  final DateTime uploadedAt;
  final DateTime? syncedAt;

  FileMetadataModel({
    required this.id,
    required this.projectId,
    this.messageId,
    required this.originalFilename,
    required this.fileSize,
    required this.mimeType,
    this.localPath,
    this.cloudUrl,
    required this.uploadedAt,
    this.syncedAt,
  });

  // Convert from Map (SQLite)
  factory FileMetadataModel.fromMap(Map<String, dynamic> map) {
    return FileMetadataModel(
      id: map['id'] as String,
      projectId: map['project_id'] as String,
      messageId: map['message_id'] as String?,
      originalFilename: map['original_filename'] as String,
      fileSize: map['file_size'] as int,
      mimeType: map['mime_type'] as String,
      localPath: map['local_path'] as String?,
      cloudUrl: map['cloud_url'] as String?,
      uploadedAt:
          DateTime.fromMillisecondsSinceEpoch(map['uploaded_at'] as int),
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
      'message_id': messageId,
      'original_filename': originalFilename,
      'file_size': fileSize,
      'mime_type': mimeType,
      'local_path': localPath,
      'cloud_url': cloudUrl,
      'uploaded_at': uploadedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
    };
  }

  // Convert from Firestore
  factory FileMetadataModel.fromFirestore(
      Map<String, dynamic> data, String id) {
    return FileMetadataModel(
      id: id,
      projectId: data['projectId'] as String,
      messageId: data['messageId'] as String?,
      originalFilename: data['originalFilename'] as String,
      fileSize: data['fileSize'] as int,
      mimeType: data['mimeType'] as String,
      localPath: null,
      cloudUrl: data['cloudUrl'] as String?,
      uploadedAt: (data['uploadedAt'] as dynamic).toDate(),
      syncedAt: null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'projectId': projectId,
      'messageId': messageId,
      'originalFilename': originalFilename,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'cloudUrl': cloudUrl,
      'uploadedAt': uploadedAt,
    };
  }

  FileMetadataModel copyWith({
    String? id,
    String? projectId,
    String? messageId,
    String? originalFilename,
    int? fileSize,
    String? mimeType,
    String? localPath,
    String? cloudUrl,
    DateTime? uploadedAt,
    DateTime? syncedAt,
  }) {
    return FileMetadataModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      messageId: messageId ?? this.messageId,
      originalFilename: originalFilename ?? this.originalFilename,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      localPath: localPath ?? this.localPath,
      cloudUrl: cloudUrl ?? this.cloudUrl,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
