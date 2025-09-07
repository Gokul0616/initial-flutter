import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/video_provider.dart';
import 'providers/user_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/socket_provider.dart';
import 'providers/story_provider.dart';
import 'providers/message_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style (status bar, navigation bar)
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Lock orientation to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const TikTokCloneApp());
}

class TikTokCloneApp extends StatelessWidget {
  const TikTokCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Update system UI overlay style based on theme
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: themeProvider.isDarkMode 
                  ? Brightness.light 
                  : Brightness.dark,
              systemNavigationBarColor: themeProvider.isDarkMode 
                  ? const Color(0xFF000000)
                  : const Color(0xFFFFFFFF),
              systemNavigationBarIconBrightness: themeProvider.isDarkMode 
                  ? Brightness.light 
                  : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'TikTok Clone',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getThemeData(themeProvider.currentTheme),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}