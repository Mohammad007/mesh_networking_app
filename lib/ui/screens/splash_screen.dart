import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../../core/permissions/permission_service.dart';
import '../../data/local_db/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _permissionService = PermissionService();
  String _statusText = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Initialize database
    setState(() => _statusText = 'Setting up database...');
    await Future.delayed(const Duration(milliseconds: 500));
    await DatabaseService.init();

    // Check permissions
    setState(() => _statusText = 'Checking permissions...');
    await Future.delayed(const Duration(milliseconds: 500));
    final hasPermissions = await _permissionService.checkAllPermissions();

    // Check Bluetooth & Wi-Fi
    setState(() => _statusText = 'Checking connectivity...');
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to next screen
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    if (hasPermissions) {
      // Check if username is set
      final username = DatabaseService.getSetting('username');
      if (username == null) {
        Navigator.pushReplacementNamed(context, '/username-setup');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/permissions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Main content - centered
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      FadeInDown(
                        duration: const Duration(milliseconds: 800),
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: AppTheme.glowShadow,
                          ),
                          child: const Icon(
                            Icons.hub,
                            size: 70,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceXL),

                      // App Name
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Mesh Network',
                          style: Theme.of(context).textTheme.displayMedium
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceS),

                      // Subtitle
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'SECURE OFFLINE MESSAGING',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.primaryColor,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w500,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceXXL),

                      // Status with loading
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 600),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                                backgroundColor: AppTheme.surfaceColor,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spaceM),
                            Text(
                              _statusText,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom - System Check Icons
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 800),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatusIndicator(Icons.bluetooth, 'Bluetooth'),
                      const SizedBox(width: AppTheme.spaceXL),
                      _buildStatusIndicator(Icons.wifi, 'Wi-Fi Direct'),
                      const SizedBox(width: AppTheme.spaceXL),
                      _buildStatusIndicator(Icons.storage, 'Storage'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceS),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(height: AppTheme.spaceXS),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
