import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/radar_animation.dart';
import '../../providers/mesh_provider.dart';
import '../../data/models/user_model.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start discovery
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeshProvider>().startDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              Expanded(
                child: Consumer<MeshProvider>(
                  builder: (context, provider, child) {
                    final devices = provider.discoveredDevices.values.toList();
                    final isScanning = provider.isDiscovering;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spaceL),
                      child: Column(
                        children: [
                          // Radar Animation
                          FadeInDown(
                            child: RadarAnimation(
                              deviceCount: devices.length,
                              isScanning: isScanning,
                            ),
                          ),

                          const SizedBox(height: AppTheme.spaceL),

                          // Status
                          FadeInUp(
                            delay: const Duration(milliseconds: 100),
                            child: Text(
                              isScanning
                                  ? 'Scanning for nearby devices...'
                                  : 'Tap to scan',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.primaryColor),
                            ),
                          ),

                          const SizedBox(height: AppTheme.spaceS),

                          // Device count
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              '${devices.length} devices found',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),

                          const SizedBox(height: AppTheme.spaceXL),

                          // Scan button
                          if (!isScanning)
                            FadeInUp(
                              delay: const Duration(milliseconds: 300),
                              child: PrimaryButton(
                                text: 'Start Scanning',
                                icon: Icons.radar,
                                onPressed: () => provider.startDiscovery(),
                              ),
                            ),

                          if (isScanning)
                            FadeInUp(
                              delay: const Duration(milliseconds: 300),
                              child: PrimaryButton(
                                text: 'Stop Scanning',
                                icon: Icons.stop,
                                onPressed: () => provider.stopDiscovery(),
                                color: AppTheme.errorColor,
                              ),
                            ),

                          const SizedBox(height: AppTheme.spaceXL),

                          // Devices list
                          if (devices.isEmpty && !isScanning)
                            _buildEmptyState()
                          else
                            ...devices.map(
                              (device) => _buildDeviceCard(device, provider),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceL),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Discovering Nodes',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                'Auto-discovering nearby mesh nodes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(UserModel device, MeshProvider provider) {
    final isConnected = provider.connectedNodes.containsKey(device.id);

    return FadeInLeft(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
        child: GlassCard(
          showGlow: isConnected,
          onTap: isConnected ? null : () => _connectToDevice(device, provider),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isConnected
                      ? AppTheme.primaryGradient
                      : LinearGradient(
                          colors: [
                            AppTheme.surfaceColor,
                            AppTheme.surfaceColor,
                          ],
                        ),
                ),
                child: Icon(
                  Icons.person,
                  color: isConnected ? Colors.black : AppTheme.primaryColor,
                  size: 30,
                ),
              ),

              const SizedBox(width: AppTheme.spaceM),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.username,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(width: AppTheme.spaceXS),
                        Text(
                          device.distanceText,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppTheme.spaceM),
                        Icon(
                          Icons.signal_cellular_alt,
                          size: 14,
                          color: _getSignalColor(device.signalStrength ?? -100),
                        ),
                        const SizedBox(width: AppTheme.spaceXS),
                        Text(
                          '${device.signalStrength ?? '?'} dBm',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status/Action
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spaceM,
                    vertical: AppTheme.spaceS,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: AppTheme.spaceXS),
                      Text(
                        'Connected',
                        style: TextStyle(
                          color: AppTheme.successColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.link, color: AppTheme.primaryColor),
                  onPressed: () => _connectToDevice(device, provider),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeInUp(
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: 80,
            color: AppTheme.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'No devices found',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.textTertiary),
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            'Make sure Bluetooth and Wi-Fi are enabled',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(int signalStrength) {
    if (signalStrength > -50) return AppTheme.successColor;
    if (signalStrength > -70) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  void _connectToDevice(UserModel device, MeshProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text('Connect to ${device.username}?'),
        content: Text(
          'Request connection to this mesh node?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.connectToDevice(device.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connection request sent')),
              );
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
