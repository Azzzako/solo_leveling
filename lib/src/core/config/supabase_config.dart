import 'supabase_config.local.dart';

abstract final class SupabaseConfig {
  static String get url {
    const fromEnv = String.fromEnvironment('SUPABASE_URL');
    return SupabaseLocalConfig.url.isNotEmpty
        ? SupabaseLocalConfig.url
        : fromEnv;
  }

  static String get anonKey {
    const fromEnv = String.fromEnvironment('SUPABASE_ANON_KEY');
    return SupabaseLocalConfig.anonKey.isNotEmpty
        ? SupabaseLocalConfig.anonKey
        : fromEnv;
  }

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;

  static String get missingFieldsMessage {
    final missing = <String>[
      if (url.isEmpty) 'SUPABASE_URL',
      if (anonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    return 'Faltan ${missing.join(' y ')} en la configuración';
  }
}
