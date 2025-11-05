class AppConstants {
  // App Info
  static const String appName = 'Manus Personal App';
  static const String appVersion = '0.1.0';

  // Message Senders
  static const String senderUser = 'user';
  static const String senderManus = 'manus';

  // Knowledge Categories
  static const String categoryInsight = 'insight';
  static const String categoryRule = 'rule';
  static const String categoryPattern = 'pattern';
  static const String categoryPreference = 'preference';
  static const String categoryOther = 'other';

  static const List<String> knowledgeCategories = [
    categoryInsight,
    categoryRule,
    categoryPattern,
    categoryPreference,
    categoryOther,
  ];

  // Storage Paths
  static const String localStoragePath = 'manus_files';
  static const String cloudStorageBasePath = 'users';

  // Sync Settings
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;

  // UI Settings
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const int maxMessageLength = 5000;
}
