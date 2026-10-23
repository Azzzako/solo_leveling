import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gotrue/gotrue.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/widgets/system_widgets.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _registering = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final loading = auth.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.radar,
                    color: AppColors.systemGlow,
                    size: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'SOLO LEVELING',
                    textAlign: TextAlign.center,
                    style: AppTypography.screenTitle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Inicia sesión para abrir tu sistema',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption,
                  ),
                  const SizedBox(height: 28),
                  SystemPanel(
                    glow: true,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SystemLabel(
                            _registering ? 'NUEVA CUENTA' : 'ACCESO',
                            color: AppColors.systemGlow,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _email,
                            enabled: !loading,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            decoration: const InputDecoration(
                              labelText: 'Correo',
                              hintText: 'cazador@correo.com',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            enabled: !loading,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            autofillHints: [
                              _registering
                                  ? AutofillHints.newPassword
                                  : AutofillHints.password,
                            ],
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          if (auth.hasError) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorText(auth.error),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                          if (!SupabaseConfig.isConfigured) ...[
                            const SizedBox(height: 12),
                            Text(
                              SupabaseConfig.missingFieldsMessage,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: loading || !SupabaseConfig.isConfigured
                                ? null
                                : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.systemBlue,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    _registering ? 'CREAR CUENTA' : 'ENTRAR',
                                    style: AppTypography.panelTitle.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: loading
                                ? null
                                : () => setState(
                                    () => _registering = !_registering,
                                  ),
                            child: Text(
                              _registering
                                  ? 'Ya tengo cuenta'
                                  : 'Crear una cuenta nueva',
                              style: AppTypography.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cada cuenta guarda su propio progreso en este dispositivo.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _errorText(Object? error) {
    if (error is! AuthException) {
      return 'No se pudo conectar con el servidor.';
    }
    if (error.statusCode == '429') {
      return 'Demasiados intentos seguidos. Espera unos minutos.';
    }
    if (error.code == 'email_address_invalid') {
      return 'Ese correo no parece válido.';
    }
    if (error.code == 'user_already_exists' || error.statusCode == '422') {
      return 'Ese correo ya tiene cuenta.';
    }
    if (!_registering &&
        (error.statusCode == '400' ||
            error.statusCode == '401' ||
            error.code == 'invalid_credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    return error.message;
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) return;
    if (!SupabaseConfig.isConfigured || ref.read(authProvider).isLoading) {
      return;
    }

    TextInput.finishAutofillContext();
    final controller = ref.read(authProvider.notifier);
    if (_registering) {
      await controller.signUp(email: email, password: password);
    } else {
      await controller.signIn(email: email, password: password);
    }
  }
}
