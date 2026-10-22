// Credenciales de tu proyecto de Supabase.
// Llénalas con Project Settings → API (URL y "publishable key").
// Esta clave está pensada para ir en el cliente (reemplaza a la antigua anon
// key), pero si prefieres no subirla al repositorio, deja las dos vacías y
// compila con:
//   --dart-define=SUPABASE_URL=https://xxxx.supabase.co
//   --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
// La app usa Supabase solo para el login: ningún dato de progreso se sube.
abstract final class SupabaseLocalConfig {
  static const url = '';
  static const anonKey = '';
}
