# Configurar Supabase (solo identidad)

La app usa Supabase **únicamente para el login**. Los datos de cada cuenta
(XP, misiones, racha, metas) viven en un SQLite propio dentro del dispositivo;
nada se sube a la nube.

## 1. Crear el proyecto

1. New project en <https://supabase.com/dashboard>.
2. Authentication → Sign In / Providers → **Email** activado.
   En Project Settings → API aparecen la **URL** y la **publishable key**
   (`sb_publishable_…`, reemplaza a la antigua `anon` key).
3. En Authentication → Settings: si quieres confirmar el correo al registrarse,
   deja *Confirm email* activado; si quieres entrar al instante, desactívalo.

## 2. Poner las claves en la app

Las claves viven en un archivo `.env` en la raíz del proyecto, que **no se sube
a git** (está en `.gitignore`). El repo es público: nunca pongas la URL ni la
key dentro del código.

```bash
cp .env.example .env    # y llena SUPABASE_URL y SUPABASE_ANON_KEY
```

```dotenv
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=sb_publishable_...
```

Todos los comandos que compilan la app llevan el archivo:

```bash
flutter run --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
flutter build ios --dart-define-from-file=.env
flutter build web --dart-define-from-file=.env
```

Si faltan, la pantalla de login lo avisa y el botón de entrar queda
desactivado. La publishable key está pensada para ir dentro del cliente (no da
acceso a datos: el progreso vive en el teléfono), pero protege el proyecto en
Supabase: confirma el correo al registrarse o activa captcha para que nadie
abuse de los registros.

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
