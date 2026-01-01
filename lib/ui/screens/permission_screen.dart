import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../../core/permissions/permission_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final _permissionService = PermissionService();
  Map<String, PermissionDetail> _permissions = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPermissions();
  }

  Future<void> _loadPermissions() async {
    final permissions = await _permissionService.getPermissionDetails();
    setState(() => _permissions = permissions);
  }

  Future<void> _requestAllPermissions() async {
    setState(() => _isLoading = true);

    await _permissionService.requestAllPermissions();
    await _loadPermissions();

    setState(() => _isLoading = false);

    // Check if all granted
    if (_permissions.values.every((p) => p.isGranted)) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/username-setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                FadeInDown(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.primaryColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: AppTheme.spaceL),

                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Setup Permissions',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),

                const SizedBox(height: AppTheme.spaceS),

                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'To enable mesh networking, we need access to nearby devices',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),

                const SizedBox(height: AppTheme.spaceXL),

                // Permissions List
                Expanded(
                  child: ListView(
                    children: _permissions.entries.map((entry) {
                      return FadeInLeft(
                        delay: Duration(
                          milliseconds: 300 + (entry.key.hashCode % 300),
                        ),
                        child: _buildPermissionCard(entry.value),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: AppTheme.spaceL),

                // Continue Button
                FadeInUp(
                  child: PrimaryButton(
                    text: 'Start Messenging →',
                    onPressed: _isLoading ? null : _requestAllPermissions,
                    isLoading: _isLoading,
                    icon: Icons.arrow_forward,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionCard(PermissionDetail detail) {
    final IconData iconData;
    switch (detail.icon) {
      case 'bluetooth':
        iconData = Icons.bluetooth;
        break;
      case 'location_on':
        iconData = Icons.location_on;
        break;
      case 'devices':
        iconData = Icons.devices;
        break;
      default:
        iconData = Icons.circle;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: GlassCard(
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              decoration: BoxDecoration(
                color: detail.isGranted
                    ? AppTheme.successColor.withOpacity(0.2)
                    : AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Icon(
                iconData,
                color: detail.isGranted
                    ? AppTheme.successColor
                    : AppTheme.primaryColor,
                size: 28,
              ),
            ),

            const SizedBox(width: AppTheme.spaceM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    detail.description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),

            // Status
            Icon(
              detail.isGranted ? Icons.check_circle : Icons.circle_outlined,
              color: detail.isGranted
                  ? AppTheme.successColor
                  : AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
