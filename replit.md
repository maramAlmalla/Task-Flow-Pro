# Overview

This is a Flutter MVVM + Clean Architecture Todo App that demonstrates production-ready mobile development patterns. The application implements comprehensive task management with features like priority levels, due dates, calendar integration, local notifications, and internationalization support for English and Arabic. Built with Clean Architecture principles, it provides a clear separation between domain logic, data persistence, and presentation layers while maintaining MVVM patterns for reactive state management.

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
- Bottom navigation for main app sections (Tasks, Calendar, Settings)
- Modal sheets and dialogs for task creation and editing workflows

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

## UI Components & Animations
- **lottie**: Vector animations for splash screen and onboarding
- **table_calendar**: Calendar widget for task date visualization
- **flutter_slidable**: Swipe actions for task list items
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