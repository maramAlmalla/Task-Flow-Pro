import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/di/di.dart';

/// Theme selection page for choosing app theme
/// Shows after onboarding completion or from settings
class ThemeSelectionPage extends ConsumerWidget {
  final bool isOnboarding;

  const ThemeSelectionPage({super.key, this.isOnboarding = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final themeNotifier = ref.read(themeModeProvider.notifier);
    final onboardingNotifier = ref.read(onboardingCompletedProvider.notifier);

    return Scaffold(
      appBar: isOnboarding 
          ? null 
          : AppBar(
              title: Text('theme_selection'.tr()),
            ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isOnboarding) ...[
                const SizedBox(height: 32),
                Text(
                  'choose_your_theme'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'theme_selection_description'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Theme options
              Expanded(
                child: Column(
                  children: [
                    _buildThemeOption(
                      context,
                      'light'.tr(),
                      'light_theme_description'.tr(),
                      Icons.light_mode,
                      'light',
                      currentTheme,
                      () => themeNotifier.setThemeMode('light'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildThemeOption(
                      context,
                      'dark'.tr(),
                      'dark_theme_description'.tr(),
                      Icons.dark_mode,
                      'dark',
                      currentTheme,
                      () => themeNotifier.setThemeMode('dark'),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    _buildThemeOption(
                      context,
                      'system'.tr(),
                      'system_theme_description'.tr(),
                      Icons.auto_mode,
                      'system',
                      currentTheme,
                      () => themeNotifier.setThemeMode('system'),
                    ),
                  ],
                ),
              ),

              if (isOnboarding) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await onboardingNotifier.completeOnboarding();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/home');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'get_started'.tr(),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual theme option
  Widget _buildThemeOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    String themeValue,
    String currentTheme,
    VoidCallback onTap,
  ) {
    final isSelected = currentTheme == themeValue;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).primaryColor 
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected 
                    ? Colors.white 
                    : Theme.of(context).iconTheme.color,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Theme.of(context).primaryColor : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}