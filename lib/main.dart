import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/notifications/notification_service.dart';
import 'core/security/lock_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation des notifications locales
  await NotificationService.initialize();

  // Création du ProviderContainer pour initialiser le verrou avant le premier rendu
  final container = ProviderContainer();
  await container.read(lockProvider.notifier).initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const IntimaApp(),
    ),
  );
}
