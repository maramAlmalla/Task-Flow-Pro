# Overview

This is a Flutter MVVM + Clean Architecture Todo App with productivity features including Pomodoro timer, screen time tracking, and Supabase-integrated reminders. The application implements comprehensive task management with priority levels, due dates, calendar integration, local notifications, and internationalization support for English and Arabic. Built with Clean Architecture principles, it provides a clear separation between domain logic, data persistence, and presentation layers while maintaining MVVM patterns for reactive state management.

## Replit Setup

Successfully configured for Replit environment (October 2025):
- **Flutter Version**: 3.32.0
- **Dart Version**: 3.8.0
- **Web Platform**: Runs on port 5000 with release mode for optimal performance
- **Build Configuration**: Uses `flutter run -d web-server --web-hostname 0.0.0.0 --web-port 5000 --release`
- **Deployment**: Configured for autoscale deployment with web build
- **Cache Control**: Meta tags added to web/index.html to prevent caching issues
- **Known Limitations**: Notifications are not supported on web platform (gracefully degrades)

# User Preferences

Preferred communication style: Simple, everyday language.

# System Architecture

## Clean Architecture Implementation
The project follows Clean Architecture with three distinct layers:
- **Domain Layer**: Contains business entities, repository interfaces, and use cases that define core business logic independent of external frameworks
- **Data Layer**: Implements repository interfaces, manages local data sources using Hive database, and handles data models with TypeAdapters for persistence
- **Presentation Layer**: Contains UI components, ViewModels for state management, and handles user interactions using MVVM pattern

## State Management Strategy
Uses Riverpod v2 for reactive state management with providers that handle:
- Task CRUD operations with automatic UI updates
- Calendar state and date selection
- Theme preferences (Light/Dark/System) with persistence
- Localization state for RTL/LTR language switching
- Settings and user preferences management

## Data Persistence Architecture
Implements Hive as the local NoSQL database solution:
- Task entities stored with TypeAdapter for efficient serialization
- Settings persistence for theme selection and onboarding completion
- Locale preferences stored locally for offline internationalization
- Automatic data migration handling for schema updates

## UI/UX Design Patterns
- **MVVM Pattern**: ViewModels manage business logic separate from UI widgets
- **Responsive Design**: Adaptive layouts for mobile and web platforms
- **Animation System**: Lottie animations for splash screen and onboarding flows
- **Theme Management**: Dynamic theme switching with system theme detection
- **Internationalization**: RTL/LTR support with easy_localization for Arabic and English

## Notification System
Local notifications implementation with platform-specific handling:
- flutter_local_notifications for native platforms (Android/iOS)
- Timezone support for accurate reminder scheduling
- Web platform gracefully degrades without notification functionality
- Background notification scheduling tied to task due dates

## Navigation and User Flow
- Splash screen with animated transitions using Lottie
- Onboarding flow for first-time users with feature introduction
- Bottom navigation with 7 sections:
  - Tasks: Main todo list with local Hive storage
  - Pomodoro: 25-minute focus timer with 5-minute breaks
  - Screen Time: Daily usage tracking with weekly charts
  - Reminders: Supabase-powered reminders with cloud sync
  - Notes: Quick note-taking feature
  - Calendar: Calendar view of tasks and events
  - Settings: Theme and preferences management
- Modal sheets and dialogs for task creation and editing workflows

## New Features (October 2025)

### Pomodoro Timer
- 25-minute focus sessions with 5-minute breaks
- Play/Pause/Reset controls
- Local notifications when timer completes
- Calm design supporting dark/light modes
- Visual countdown display with circular timer

### Screen Time Tracker
- Automatic daily usage tracking
- Persistent storage using SharedPreferences
- Weekly activity chart with fl_chart
- Real-time session monitoring
- Usage statistics with hours and minutes display

### Supabase Reminders
- Cloud-based reminder storage with Supabase
- Full CRUD operations (Create, Read, Update, Delete)
- Recurrence options: None, Daily, Weekly, Monthly
- Anonymous authentication for quick access
- Checkbox to mark reminders as done
- Row-level security policies for data protection
- Real-time sync across devices

# External Dependencies

## Core Framework
- **Flutter SDK**: Cross-platform mobile/web development framework
- **Dart**: Programming language with null safety support

## State Management & Architecture
- **flutter_riverpod**: Reactive state management with provider pattern for dependency injection and state handling
- **riverpod_annotation**: Code generation for type-safe providers

## Local Storage
- **hive**: NoSQL local database for task and settings persistence
- **hive_flutter**: Flutter integration for Hive database
- **hive_generator**: Code generation for TypeAdapters
- **shared_preferences**: Key-value storage for screen time tracking

## Cloud Storage & Backend
- **supabase_flutter**: Supabase client for cloud database and authentication
- **postgrest**: PostgreSQL REST client for Supabase
- **realtime_client**: Real-time subscription support
- **gotrue**: Authentication and user management

## UI Components & Animations
- **lottie**: Vector animations for splash screen and onboarding
- **table_calendar**: Calendar widget for task date visualization
- **flutter_slidable**: Swipe actions for task list items
- **fl_chart**: Beautiful charts for screen time visualization
- **material_design**: Material 3 design system implementation

## Notifications & Platform Services
- **flutter_local_notifications**: Local notification scheduling for task reminders
- **timezone**: Timezone handling for accurate notification timing
- **permission_handler**: Runtime permission management for notifications

## Internationalization
- **easy_localization**: Internationalization framework supporting RTL/LTR languages
- **intl**: Date/time formatting and locale-specific utilities

## Development Tools
- **flutter_lints**: Dart/Flutter linting rules for code quality
- **build_runner**: Code generation tool for Hive and Riverpod annotations

## Platform Integration
- Native Android/iOS notification channels configured
- Web platform compatibility with graceful feature degradation
- Platform-specific permission handling for notification access

## Environment Configuration
- **SUPABASE_URL**: Supabase project URL (configured via Replit Secrets)
- **SUPABASE_ANON_KEY**: Supabase anonymous key (configured via Replit Secrets)
- Credentials passed to Flutter via --dart-define flags during build

## Supabase Database Setup
The reminders feature requires a Supabase database table. Run the SQL in `supabase_setup.sql`:
1. Go to your Supabase project dashboard
2. Navigate to SQL Editor
3. Copy and execute the SQL from `supabase_setup.sql`
4. This creates the reminders table with Row Level Security policies