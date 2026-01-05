import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/theme.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/novels/novel_detail_screen.dart';
import 'screens/novels/novels_screen.dart';
import 'screens/bookmarks/bookmarks_screen.dart';
import 'screens/reader/reader_screen.dart';
import 'screens/profile/profile_screen.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize notification service
  await NotificationService().initialize();

  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Force portrait orientation
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const WignRealmApp());
}

class WignRealmApp extends StatelessWidget {
  const WignRealmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: MaterialApp(
        title: 'Wign Realm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme.copyWith(
          textTheme: GoogleFonts.poppinsTextTheme(AppTheme.darkTheme.textTheme),
        ),
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _pageRoute(const SplashScreen());
      case '/login':
        return _pageRoute(const LoginScreen());
      case '/register':
        return _pageRoute(const RegisterScreen());
      case '/home':
        return _pageRoute(const MainNavigation());
      case '/novel':
        final novelId = settings.arguments as String;
        return _pageRoute(NovelDetailScreen(novelId: novelId));
      case '/reader':
        final args = settings.arguments as Map<String, dynamic>;
        return _pageRoute(
          ReaderScreen(
            chapterId: args['chapterId'],
            novelId: args['novelId'],
            novelTitle: args['novelTitle'],
          ),
        );
      default:
        return _pageRoute(const SplashScreen());
    }
  }

  PageRoute _pageRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}

// Main Navigation with Bottom Nav Bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NovelsScreen(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
                _buildNavItem(
                  1,
                  Icons.library_books_outlined,
                  Icons.library_books,
                  'Novels',
                ),
                _buildNavItem(
                  2,
                  Icons.bookmark_outline,
                  Icons.bookmark,
                  'Saved',
                ),
                _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isActive
            ? BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppTheme.primary : AppTheme.textMuted,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
