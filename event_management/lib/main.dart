import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/events/presentation/home_screen.dart';
import 'features/events/presentation/create_event_screen.dart';
import 'features/events/presentation/event_details_screen.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/notifications/presentation/notifications_screen.dart';
import 'shared/services/firebase_service.dart';
import 'shared/models/event_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await FirebaseService.initialize();
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(
    const ProviderScope(
      child: EventEaseApp(),
    ),
  );
}

class EventEaseApp extends ConsumerWidget {
  const EventEaseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.splash:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case AppRoutes.login:
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case AppRoutes.register:
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case AppRoutes.home:
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case AppRoutes.createEvent:
            return MaterialPageRoute(builder: (_) => const CreateEventScreen());
          case AppRoutes.editEvent:
            final event = settings.arguments as EventModel?;
            return MaterialPageRoute(
              builder: (_) => CreateEventScreen(event: event),
            );
          case AppRoutes.eventDetails:
            final event = settings.arguments as EventModel;
            return MaterialPageRoute(
              builder: (_) => EventDetailsScreen(event: event),
            );
          case AppRoutes.settings:
            return MaterialPageRoute(builder: (_) => const SettingsScreen());
          case AppRoutes.notifications:
            return MaterialPageRoute(builder: (_) => const NotificationsScreen());
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
