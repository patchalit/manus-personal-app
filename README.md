# Manus Personal App

แอปพลิเคชัน Manus ส่วนตัวสำหรับ macOS และ Android

## 📋 โครงสร้างโปรเจค

```
lib/
├── main.dart                           # Entry point
├── core/                               # Core utilities
│   ├── constants/
│   │   └── app_constants.dart         # App-wide constants
│   └── utils/                          # Helper functions
├── data/                               # Data Layer
│   ├── models/                         # Data models
│   │   ├── user_model.dart
│   │   ├── project_model.dart
│   │   ├── message_model.dart
│   │   ├── knowledge_entry_model.dart
│   │   └── file_metadata_model.dart
│   ├── services/                       # Data services
│   │   ├── local_database_service.dart
│   │   └── firebase_service.dart
│   └── repositories/                   # Data repositories
├── business_logic/                     # Business Logic Layer
│   └── providers/                      # State management
└── presentation/                       # Presentation Layer
    ├── screens/                        # App screens
    └── widgets/                        # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.24.5 or higher
- Dart 3.5.4 or higher
- Firebase Project (for cloud sync)

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Add Firebase configuration files:
   - Android: `android/app/google-services.json`
   - iOS/macOS: `ios/Runner/GoogleService-Info.plist` and `macos/Runner/GoogleService-Info.plist`

4. Run the app:
   ```bash
   flutter run
   ```

## 📦 Dependencies

### Core
- `provider` - State management
- `sqflite` - Local database
- `path_provider` - File system paths

### Firebase
- `firebase_core` - Firebase initialization
- `firebase_auth` - Authentication
- `cloud_firestore` - Cloud database
- `firebase_storage` - File storage

### Utilities
- `uuid` - Unique ID generation
- `intl` - Internationalization
- `shared_preferences` - Local preferences
- `file_picker` - File selection
- `mime` - MIME type detection

## 🗄️ Database Schema

### Local Database (SQLite)
- `users` - User information
- `projects` - Project data
- `messages` - Chat messages
- `files` - File metadata
- `knowledge_entries` - Knowledge base entries

### Cloud Database (Firestore)
- Same structure as local database for sync

## 📝 Development Status

- [x] Phase 1: Architecture Design
- [x] Phase 2: Project Setup
- [ ] Phase 3: UI Development
- [ ] Phase 4: Cloud Sync Implementation
- [ ] Phase 5: Testing & Build
- [ ] Phase 6: Deployment

## 📄 License

All rights reserved to the project owner.
