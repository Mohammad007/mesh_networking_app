import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../../providers/mesh_provider.dart';
import '../../data/local_db/database_service.dart';
import '../../core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _encryptionEnabled = true;
  int _ttlLimit = AppConstants.defaultTTL;
  bool _autoConnect = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _encryptionEnabled = DatabaseService.getSetting(
        AppConstants.keyEncryptionEnabled,
        defaultValue: true,
      );
      _ttlLimit = DatabaseService.getSetting(
        AppConstants.keyTTLLimit,
        defaultValue: AppConstants.defaultTTL,
      );
      _autoConnect = DatabaseService.getSetting(
        AppConstants.keyAutoConnect,
        defaultValue: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeshProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppTheme.spaceL),
                  children: [
                    // User Info Card
                    FadeInDown(child: _buildUserInfoCard(provider)),

                    const SizedBox(height: AppTheme.spaceL),

                    // Mesh Settings
                    FadeInLeft(
                      delay: const Duration(milliseconds: 100),
                      child: _buildSectionTitle('Mesh Network'),
                    ),

                    _buildSettingCard(
                      icon: Icons.security,
                      title: 'Encryption',
                      subtitle: 'AES-256 end-to-end encryption',
                      trailing: Switch(
                        value: _encryptionEnabled,
                        onChanged: (value) async {
                          setState(() => _encryptionEnabled = value);
                          await DatabaseService.saveSetting(
                            AppConstants.keyEncryptionEnabled,
                            value,
                          );
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),

                    _buildSettingCard(
                      icon: Icons.timeline,
                      title: 'TTL Limit',
                      subtitle: 'Message hops: $_ttlLimit',
                      trailing: SizedBox(
                        width: 100,
                        child: Slider(
                          value: _ttlLimit.toDouble(),
                          min: 1,
                          max: 10,
                          divisions: 9,
                          activeColor: AppTheme.primaryColor,
                          onChanged: (value) async {
                            setState(() => _ttlLimit = value.toInt());
                            await DatabaseService.saveSetting(
                              AppConstants.keyTTLLimit,
                              value.toInt(),
                            );
                          },
                        ),
                      ),
                    ),

                    _buildSettingCard(
                      icon: Icons.wifi_tethering,
                      title: 'Auto Connect',
                      subtitle: 'Automatically connect to trusted nodes',
                      trailing: Switch(
                        value: _autoConnect,
                        onChanged: (value) async {
                          setState(() => _autoConnect = value);
                          await DatabaseService.saveSetting(
                            AppConstants.keyAutoConnect,
                            value,
                          );
                        },
                        activeColor: AppTheme.primaryColor,
                      ),
                    ),

                    const SizedBox(height: AppTheme.spaceL),

                    // Data Management
                    FadeInLeft(
                      delay: const Duration(milliseconds: 200),
                      child: _buildSectionTitle('Data Management'),
                    ),

                    _buildActionCard(
                      icon: Icons.delete_sweep,
                      title: 'Clear Message Cache',
                      subtitle: 'Delete all cached messages',
                      color: AppTheme.warningColor,
                      onTap: () => _showClearCacheDialog(provider),
                    ),

                    _buildActionCard(
                      icon: Icons.restore,
                      title: 'Reset Device',
                      subtitle: 'Clear all data and settings',
                      color: AppTheme.errorColor,
                      onTap: () => _showResetDialog(provider),
                    ),

                    const SizedBox(height: AppTheme.spaceL),

                    // Statistics
                    FadeInLeft(
                      delay: const Duration(milliseconds: 300),
                      child: _buildSectionTitle('Statistics'),
                    ),

                    _buildStatsCard(provider),

                    const SizedBox(height: AppTheme.spaceL),

                    // About
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: _buildAboutCard(),
                    ),
                  ],
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
          Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(MeshProvider provider) {
    final username = provider.currentUsername ?? 'User';
    final nodeId = DatabaseService.getSetting('node_id') ?? 'N/A';

    return GlassCard(
      showGlow: true,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Text(
                username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppTheme.spaceXS),
                Row(
                  children: [
                    Icon(Icons.tag, size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: AppTheme.spaceXS),
                    Text(
                      nodeId,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: GlassCard(
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(width: AppTheme.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: GlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppTheme.spaceM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(MeshProvider provider) {
    final stats = DatabaseService.getStatistics();

    return GlassCard(
      child: Column(
        children: [
          _buildStatRow('Total Messages', '${stats['total_messages']}'),
          const Divider(color: AppTheme.surfaceColor),
          _buildStatRow('Total Users', '${stats['total_users']}'),
          const Divider(color: AppTheme.surfaceColor),
          _buildStatRow('Pending Messages', '${provider.pendingMessagesCount}'),
          const Divider(color: AppTheme.surfaceColor),
          _buildStatRow('Connected Nodes', '${provider.connectedNodesCount}'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About MeshNet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            'Version: ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spaceS),
          Text(
            'Offline mesh networking for emergency communication',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(MeshProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Clear Message Cache?'),
        content: Text(
          'This will delete all cached messages. This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseService.clearAllMessages();
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Cache cleared')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(MeshProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Reset Device?'),
        content: Text(
          'This will delete ALL data including messages, users, and settings. This action cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.clearAllData();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/username-setup',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
