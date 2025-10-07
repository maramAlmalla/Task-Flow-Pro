import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> initialize() async {
    final supabaseUrl = const String.fromEnvironment('SUPABASE_URL', 
        defaultValue: '');
    final supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', 
        defaultValue: '');
    
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase credentials not configured');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
