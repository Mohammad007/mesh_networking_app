import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../../data/local_db/database_service.dart';
import '../../providers/mesh_provider.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _username = DatabaseService.getSetting('username', defaultValue: 'User');
    });
  }

  Future<void> _toggleMesh(MeshProvider provider) async {
    if (provider.isMeshActive) {
      await provider.stopMesh();
    } else {
      await provider.startMesh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MeshProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(provider),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spaceL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mesh Status Card
                          FadeInDown(child: _buildMeshStatusCard(provider)),

                          const SizedBox(height: AppTheme.spaceL),

                          // Quick Stats
                          FadeInLeft(
                            delay: const Duration(milliseconds: 100),
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.people,
                                    title: 'Online Nearby',
                                    value: '${provider.connectedNodesCount}',
                                    color: AppTheme.successColor,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spaceM),
                                Expanded(
                                  child: _buildStatCard(
                                    icon: Icons.pending_actions,
                                    title: 'Queue',
                                    value: '${provider.pendingMessagesCount}',
                                    color: AppTheme.warningColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppTheme.spaceL),

                          // Quick Actions
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Quick Actions',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),

                          const SizedBox(height: AppTheme.spaceM),

                          FadeInUp(
                            delay: const Duration(milliseconds: 300),
                            child: _buildActionButtons(provider),
                          ),

                          const SizedBox(height: AppTheme.spaceL),

                          // Features
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: _buildFeatureGrid(provider),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: provider.isMeshActive
              ? FadeInUp(
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.pushNamed(context, '/chat-list');
                    },
                    backgroundColor: AppTheme.primaryColor,
                    icon: const Icon(Icons.chat, color: Colors.black),
                    label: const Text(
                      'Messages',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeader(MeshProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceL),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MeshNet',
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: provider.isMeshActive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        if (provider.isMeshActive)
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceS),
                  Text(
                    provider.isMeshActive ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeshStatusCard(MeshProvider provider) {
    return GlassCard(
      showGlow: provider.isMeshActive,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceM),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: const Icon(Icons.hub, color: Colors.black, size: 32),
              ),
              const SizedBox(width: AppTheme.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXS),
                    Row(
                      children: [
                        Icon(Icons.tag, size: 14, color: AppTheme.primaryColor),
                        const SizedBox(width: AppTheme.spaceXS),
                        Text(
                          DatabaseService.getSetting(
                            'node_id',
                            defaultValue: 'N/A',
                          ),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: AppTheme.spaceM),
                        Text(
                          provider.isMeshActive
                              ? '• ${provider.connectedNodesCount} Nodes'
                              : '• Offline',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: provider.isMeshActive,
                onChanged: (value) => _toggleMesh(provider),
                activeColor: AppTheme.primaryColor,
              ),
            ],
          ),
          if (provider.isMeshActive) ...[
            const SizedBox(height: AppTheme.spaceM),
            const Divider(color: AppTheme.surfaceColor),
            const SizedBox(height: AppTheme.spaceM),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMeshInfo('Range', '~500m'),
                _buildMeshInfo('Protocol', 'P2P'),
                _buildMeshInfo('Encryption', 'AES-256'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMeshInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
        ),
        const SizedBox(height: AppTheme.spaceXS),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spaceM),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXS),
          Text(title, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MeshProvider provider) {
    return Column(
      children: [
        PrimaryButton(
          text: 'Discover Nearby',
          icon: Icons.radar,
          onPressed: provider.isMeshActive
              ? () {
                  Navigator.pushNamed(context, '/discovery');
                }
              : null,
        ),
        const SizedBox(height: AppTheme.spaceM),
        PrimaryButton(
          text: 'Emergency Broadcast',
          icon: Icons.emergency,
          onPressed: provider.isMeshActive
              ? () {
                  Navigator.pushNamed(context, '/broadcast');
                }
              : null,
          color: AppTheme.errorColor,
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(MeshProvider provider) {
    final features = [
      {'icon': Icons.chat, 'title': 'Messages', 'route': '/chat-list'},
      {'icon': Icons.map, 'title': 'Network Map', 'route': '/network-map'},
      {'icon': Icons.people, 'title': 'Connections', 'route': '/discovery'},
      {'icon': Icons.campaign, 'title': 'Broadcast', 'route': '/broadcast'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spaceM,
        mainAxisSpacing: AppTheme.spaceM,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return GlassCard(
          onTap: provider.isMeshActive
              ? () {
                  Navigator.pushNamed(context, feature['route'] as String);
                }
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                feature['icon'] as IconData,
                color: provider.isMeshActive
                    ? AppTheme.primaryColor
                    : AppTheme.textTertiary,
                size: 32,
              ),
              const SizedBox(height: AppTheme.spaceS),
              Text(
                feature['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: provider.isMeshActive
                      ? AppTheme.textPrimary
                      : AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
