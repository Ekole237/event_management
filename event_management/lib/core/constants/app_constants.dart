class AppConstants {
  // App Info
  static const String appName = 'EventEase';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String participantsCollection = 'participants';
  static const String notificationsCollection = 'notifications';

  // Storage Paths
  static const String eventImagesPath = 'events/images';
  static const String userProfilesPath = 'users/profiles';

  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Pagination
  static const int eventsPerPage = 20;
  static const int participantsPerPage = 50;

  // Event Defaults
  static const int defaultMaxParticipants = 100;
  static const int reminderHoursBefore = 24;

  // Image Constraints
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 85;
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String eventsList = '/events';
  static const String eventDetails = '/event-details';
  static const String createEvent = '/create-event';
  static const String editEvent = '/edit-event';
  static const String participants = '/participants';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String adminDashboard = '/admin';
  static const String userManagement = '/admin/users';
}
