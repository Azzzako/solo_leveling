abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');

  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static String get missingFieldsMessage {
    final missing = <String>[
      if (url.isEmpty) 'SUPABASE_URL',
      if (anonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    return 'Faltan ${missing.join(' y ')}. Compila con '
        '--dart-define-from-file=.env';
  }
}
