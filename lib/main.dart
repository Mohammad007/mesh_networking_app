import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'ui/screens/permission_screen.dart';
import 'ui/screens/username_setup_screen.dart';
import 'ui/screens/home_dashboard_screen.dart';
import 'ui/screens/discovery_screen.dart';
import 'ui/screens/chat_list_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/settings_screen.dart';
import 'ui/screens/broadcast_screen.dart';
import 'ui/screens/network_map_screen.dart';
import 'providers/mesh_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A1929),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MeshNetApp());
}

class MeshNetApp extends StatelessWidget {
  const MeshNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MeshProvider(),
      child: MaterialApp(
        title: 'MeshNet - Offline Messaging',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/permissions': (context) => const PermissionScreen(),
          '/username-setup': (context) => const UsernameSetupScreen(),
          '/home': (context) => const HomeDashboardScreen(),
          '/discovery': (context) => const DiscoveryScreen(),
          '/chat-list': (context) => const ChatListScreen(),
          '/broadcast': (context) => const BroadcastScreen(),
          '/network-map': (context) => const NetworkMapScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/chat') {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args != null) {
              return MaterialPageRoute(
                builder: (context) => ChatScreen(
                  userId: args['userId'] as String,
                  username: args['username'] as String,
                ),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}

// Placeholder screen for routes not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction,
                size: 80,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                '$title Screen',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Coming Soon',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
