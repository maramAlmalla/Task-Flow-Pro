import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'core/init/app_init.dart';
import 'core/di/di.dart';
import 'features/tasks/presentation/pages/tasks_page.dart';
import 'features/calendar/presentation/pages/calendar_page.dart';
import 'features/settings/presentation/pages/theme_selection_page.dart';

/// Main entry point for the Flutter Todo App
/// Implements MVVM + Clean Architecture with Riverpod state management
void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize localization
  await EasyLocalization.ensureInitialized();
  
  // Initialize the application (Hive, notifications, etc.)
  await AppInit.init();

  // Run the app
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'SA'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      child: ProviderScope(
        child: const TodoApp(),
      ),
    ),
  );
}

/// Main application widget with theme and routing configuration
class TodoApp extends ConsumerWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isOnboardingCompleted = ref.watch(onboardingCompletedProvider);

    return MaterialApp(
      title: 'app_title'.tr(),
      
      // Localization configuration
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      
      // Theme configuration
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _getThemeMode(themeMode),
      
      // Debug configuration
      debugShowCheckedModeBanner: false,
      
      // Home page based on onboarding status
      home: isOnboardingCompleted 
          ? const MainNavigationPage() 
          : const OnboardingFlow(),
      
      // Route configuration
      routes: {
        '/home': (context) => const MainNavigationPage(),
        '/onboarding': (context) => const OnboardingFlow(),
        '/theme-selection': (context) => const ThemeSelectionPage(),
      },
    );
  }

  /// Convert string theme mode to ThemeMode enum
  ThemeMode _getThemeMode(String themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Light theme configuration
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  /// Dark theme configuration
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// Onboarding flow widget
class OnboardingFlow extends StatelessWidget {
  const OnboardingFlow({super.key});

  @override
  Widget build(BuildContext context) {
    // For this demo, skip onboarding and go directly to theme selection
    return const ThemeSelectionPage(isOnboarding: true);
  }
}

/// Main navigation page with bottom navigation
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TasksPage(),
    const CalendarPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.task_alt),
            label: 'tasks'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: 'calendar'.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'settings'.tr(),
          ),
        ],
      ),
    );
  }
}

/// Settings page (placeholder for now)
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);
    // final themeNotifier = ref.read(themeModeProvider.notifier);
    final localeNotifier = ref.read(localeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme setting
          Card(
            child: ListTile(
              leading: const Icon(Icons.palette),
              title: Text(
                (currentTheme is String ? currentTheme : currentTheme.toString()).tr(),
              ),
              subtitle: Text(currentTheme.tr()),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ThemeSelectionPage(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Language setting
          Card(
            child: ListTile(
              leading: const Icon(Icons.language),
              title: Text('language'.tr()),
              subtitle: Text(currentLocale == 'ar' ? 'العربية' : 'English'),
              trailing: Switch(
  value: context.locale.languageCode == 'ar',
  onChanged: (value) async {
    final newLocale = value ? const Locale('ar', 'SA') : const Locale('en', 'US');
    
    if (context.mounted) {
      await context.setLocale(newLocale);
    }

   
    await localeNotifier.setLocale(newLocale.toString());
  },
),


            ),
          ),

          const SizedBox(height: 32),

          // App info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'app_info'.tr(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text('Version: 1.0.0'),
                  Text('Built with Flutter & Clean Architecture'),
                  Text('State Management: Riverpod'),
                  Text('Local Storage: Hive'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
