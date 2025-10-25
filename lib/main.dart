import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_boxes.dart';
import 'core/utils/web_cookies.dart';
import 'services/auth/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await HiveBoxes.init();
  runApp(const ProviderScope(child: AppRoot()));
}

class AppRoot extends ConsumerWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = AppRouter.createRouter();
    _restoreSessionIfAny();
    return MaterialApp.router(
      title: 'NipponGo',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
    );
  }
}

Future<void> _restoreSessionIfAny() async {
  try {
    final String? email = await getPersistentFlag('signed_in_email');
    if (email == null) return;
    final AuthService auth = const AuthService();
    final Box box = Hive.box(HiveBoxes.users);
    final dynamic raw = box.get(email);
    if (raw is Map) {
      final Map<String, dynamic> u = Map<String, dynamic>.from(raw as Map);
      await Hive.box(HiveBoxes.auth).put('current_user', {
        'username': u['username'],
        'email': u['email'],
        'bio': u['bio'],
        'photoPath': u['photoPath'],
      });
    }
  } catch (_) {}
}
