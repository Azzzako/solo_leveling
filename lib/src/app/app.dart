import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/core_providers.dart';
import 'mexico_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class SoloLevelingApp extends ConsumerStatefulWidget {
  const SoloLevelingApp({super.key});

  @override
  ConsumerState<SoloLevelingApp> createState() => _SoloLevelingAppState();
}

class _SoloLevelingAppState extends ConsumerState<SoloLevelingApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(todayProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Solo Leveling',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      locale: appLocale,
      supportedLocales: const [appLocale],
      localizationsDelegates: MexicoMaterialLocalizations.delegates,
      routerConfig: router,
    );
  }
}
