# Flutter MVVM + Clean Architecture Todo App

A production-ready Flutter application implementing MVVM + Clean Architecture pattern with comprehensive task management features.

## 🚀 Features

### Core Functionality
- ✅ **Task Management**: Create, read, update, delete tasks with full CRUD operations
- ✅ **Priority System**: High, Medium, Low priority levels with visual indicators
- ✅ **Due Date Management**: Set due dates and times with automatic overdue detection
- ✅ **Task Completion**: Toggle task completion status with visual feedback
- ✅ **Search & Filter**: Search tasks and filter by status, priority, and date

### Advanced Features
- 📅 **Calendar Integration**: View tasks organized by date using TableCalendar
- 🔔 **Local Notifications**: Schedule reminders for task due dates (native platforms)
- 🌍 **Internationalization**: Support for English and Arabic (RTL) languages
- 🎨 **Theme System**: Light, Dark, and System theme selection with persistence
- 📱 **Responsive Design**: Optimized for both mobile and web platforms
- 🗂️ **Local Storage**: Persistent data storage using Hive database

### Technical Features
- 🏗️ **Clean Architecture**: Domain, Data, and Presentation layers
- 🎯 **MVVM Pattern**: Clear separation of concerns with ViewModels
- 🔄 **State Management**: Riverpod v2 for reactive state management
- 📦 **Dependency Injection**: Centralized DI container with providers
- ✨ **Animations**: Smooth transitions and Lottie animations
- 🧪 **Error Handling**: Comprehensive exception handling and validation

## 🏗️ Architecture

### Clean Architecture Layers

```
lib/
├── core/                       # Core utilities and services
│   ├── errors/                 # Exception definitions
│   ├── init/                   # App initialization
│   ├── notifications/          # Notification service
│   ├── di/                     # Dependency injection
│   └── utils/                  # Validation utilities
├── features/
│   └── tasks/
│       ├── data/               # Data layer
│       │   ├── datasources/    # Local data sources
│       │   ├── models/         # Data models (Hive)
│       │   └── repositories/   # Repository implementations
│       ├── domain/             # Domain layer
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business use cases
│       └── presentation/       # Presentation layer
│           ├── controllers/    # State notifiers (ViewModels)
│           ├── pages/          # UI pages (Views)
│           └── widgets/        # Reusable widgets
```

### Key Design Patterns
- **MVVM**: Model-View-ViewModel for UI logic separation
- **Repository Pattern**: Abstract data access layer
- **Use Case Pattern**: Encapsulated business logic
- **Dependency Injection**: Loose coupling and testability
- **Observer Pattern**: Reactive state management with Riverpod

## 📱 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.9      # State management
  hive: ^2.2.3                  # Local database
  hive_flutter: ^1.1.0          # Flutter Hive integration
  flutter_local_notifications: ^16.3.0  # Push notifications
  timezone: ^0.9.2              # Timezone handling
  table_calendar: ^3.0.9        # Calendar widget
  lottie: ^2.7.0               # Animations
  flutter_slidable: ^3.0.1     # Swipe actions
  easy_localization: ^3.0.3    # Internationalization

dev_dependencies:
  build_runner: ^2.4.7          # Code generation
  hive_generator: ^2.0.1        # Hive model generation
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.0.0 or higher)

### Installation Steps

1. **Clone and Setup**
   ```bash
   # Run the setup script
   chmod +x scripts/setup.sh
   ./scripts/setup.sh
   ```

2. **Manual Setup** (if script fails)
   ```bash
   # Get dependencies
   flutter pub get
   
   # Generate code (if needed)
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the Application**
   ```bash
   # For web (Replit compatible)
   flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000
   
   # For mobile development
   flutter run
   ```

### Platform-Specific Setup

#### Android Notifications
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />

<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

#### iOS Notifications
Add to `ios/Runner/AppDelegate.swift`:
```swift
if #available(iOS 10.0, *) {
  UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
}
```

## 🌐 Deployment

### Web Deployment
```bash
# Build for web
flutter build web --release

# Deploy the build/web directory to your hosting service
```

### Mobile Deployment
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🎯 Usage

### Basic Operations
1. **Add Task**: Use the floating action button to create new tasks
2. **Complete Task**: Tap the checkbox to mark tasks as complete
3. **Edit Task**: Swipe right on a task card to edit
4. **Delete Task**: Swipe right on a task card to delete
5. **View Details**: Tap on a task to see full details

### Advanced Features
- **Filter Tasks**: Use the filter menu in the app bar
- **Search**: Use the search bar to find specific tasks
- **Calendar View**: Switch to calendar tab to see tasks by date
- **Theme**: Go to settings to change app theme
- **Language**: Toggle between English and Arabic in settings

## 🧪 Testing

The application includes comprehensive error handling and validation:

- **Input Validation**: All forms validate user input
- **Error States**: Graceful handling of storage and network errors
- **Loading States**: Visual feedback during operations
- **Empty States**: Helpful messages when no data is available

## 🔧 Configuration

### Customization Options
- **Theme Colors**: Modify `_lightTheme` and `_darkTheme` in `main.dart`
- **Translations**: Add new languages in `assets/translations/`
- **Animations**: Replace Lottie files in `assets/lottie/`
- **Notifications**: Configure timing and content in `NotificationsService`

### Environment Variables
- No external API keys required for basic functionality
- Notifications work offline using local scheduling

## 📄 License

This project is a demonstration of Flutter Clean Architecture patterns and is provided as-is for educational purposes.

## 🤝 Contributing

This is a showcase project demonstrating Flutter best practices including:
- Clean Architecture implementation
- MVVM pattern with Riverpod
- Proper error handling and validation
- Internationalization support
- Local data persistence
- Cross-platform compatibility

---

**Built with ❤️ using Flutter and Clean Architecture principles**