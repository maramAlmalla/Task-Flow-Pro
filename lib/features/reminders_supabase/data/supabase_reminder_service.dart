import '../../../core/supabase/supabase_config.dart';

class SupabaseReminderService {
  static const String tableName = 'reminders';
  
  final _client = SupabaseConfig.client;

  Future<List<Map<String, dynamic>>> getReminders(String userId) async {
    final response = await _client
        .from(tableName)
        .select()
        .eq('user_id', userId)
        .order('time', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addReminder({
    required String userId,
    required String title,
    required DateTime time,
    required String repeat,
  }) async {
    await _client.from(tableName).insert({
      'user_id': userId,
      'title': title,
      'time': time.toIso8601String(),
      'repeat': repeat,
      'is_done': false,
    });
  }

  Future<void> updateReminder({
    required int id,
    required String title,
    required DateTime time,
    required String repeat,
  }) async {
    await _client.from(tableName).update({
      'title': title,
      'time': time.toIso8601String(),
      'repeat': repeat,
    }).eq('id', id);
  }

  Future<void> toggleDone(int id, bool isDone) async {
    await _client.from(tableName).update({
      'is_done': isDone,
    }).eq('id', id);
  }

  Future<void> deleteReminder(int id) async {
    await _client.from(tableName).delete().eq('id', id);
  }
}
