# Configurar Supabase (solo identidad)

La app usa Supabase **únicamente para el login**. Los datos de cada cuenta
(XP, misiones, racha, metas) viven en un SQLite propio dentro del dispositivo;
nada se sube a la nube.

## 1. Crear el proyecto

1. New project en <https://supabase.com/dashboard>.
2. Authentication → Sign In / Providers → **Email** activado.
   En Project Settings → API aparecen la **URL** y la **publishable key**
   (`sb_publishable_…`, sustituye a la antigua `anon` key).
3. En Authentication → Settings: si quieres confirmar el correo al registrarse,
   deja *Confirm email* activado; si quieres entrar al instante, desactívalo.

## 2. Poner las claves en la app

Opción A (fichero):

Edita `lib/src/core/config/supabase_config.local.dart` con la URL y la
publishable key. La clave va en el mismo hueco que la antigua `anonKey`.

La publishable key está pensada para ir dentro del cliente, pero si prefieres
no publicarla en el repositorio, deja el fichero vacío y usa la opción B.

Opción B (dart-define, para CI o builds):

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
flutter build apk --dart-define=SUPABASE_URL=... \
                  --dart-define=SUPABASE_ANON_KEY=sb_publishable_...
```

Si faltan las dos, la pantalla de login lo avisa y el botón de entrar queda
desactivado.

## 3. Qué pasa con el progreso anterior

- El primer usuario que entra reclama el progreso que ya estaba en el
  dispositivo (`hunter_total_xp`, `hunter_streak`, ...) y la base de datos
  `solo_leveling.sqlite`, que se copia a `solo_leveling_<userId>.sqlite`.
- Los usuarios siguientes empiezan de cero en su propio archivo.

## 4. Sesión sin red

La sesión (access token + usuario) se guarda en `SharedPreferences`. Al abrir
la app:

- sesión vigente → se usa tal cual, sin tocar la red;
- sesión caducada y con red → se renueva contra Supabase;
- sin red o token rechazado → se entra con la sesión cacheada (`offline: true`)
  y todo el progreso sigue disponible.

Solo cerrar sesión (icono de salida en la cabecera) borra la sesión local.
