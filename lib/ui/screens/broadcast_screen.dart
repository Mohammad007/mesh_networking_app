import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../../providers/mesh_provider.dart';
import '../../core/constants/app_constants.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final _messageController = TextEditingController();
  String? _selectedTemplate;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spaceL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Card
                      FadeInDown(child: _buildInfoCard(provider)),

                      const SizedBox(height: AppTheme.spaceL),

                      // Emergency Templates
                      FadeInLeft(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Emergency Templates',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceM),

                      _buildEmergencyTemplates(),

                      const SizedBox(height: AppTheme.spaceL),

                      // Custom Message
                      FadeInLeft(
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          'Custom Message',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceM),

                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: GlassCard(
                          child: TextField(
                            controller: _messageController,
                            maxLines: 4,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'Type your broadcast message...',
                              border: InputBorder.none,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceL),

                      // Broadcast Button
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: PrimaryButton(
                          text: 'Send Broadcast Alert',
                          icon: Icons.campaign,
                          onPressed: _canSend(provider)
                              ? () => _sendBroadcast(provider)
                              : null,
                          color: AppTheme.errorColor,
                        ),
                      ),

                      const SizedBox(height: AppTheme.spaceM),

                      // Warning
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: Container(
                          padding: const EdgeInsets.all(AppTheme.spaceM),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            border: Border.all(
                              color: AppTheme.warningColor.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(
                              AppTheme.radiusMedium,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: AppTheme.warningColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spaceS),
                              Expanded(
                                child: Text(
                                  'Broadcast messages will be sent to ALL connected nodes in the mesh network',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                'Emergency Broadcast',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                'Send alerts to all nodes',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(MeshProvider provider) {
    return GlassCard(
      showGlow: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceM),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(Icons.campaign, color: AppTheme.errorColor, size: 32),
          ),
          const SizedBox(width: AppTheme.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connected to ${provider.connectedNodesCount} nodes',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Text(
                  provider.isMeshActive
                      ? 'Ready to broadcast'
                      : 'Mesh network offline',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: provider.isMeshActive
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTemplates() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.spaceM,
        mainAxisSpacing: AppTheme.spaceM,
        childAspectRatio: 1.5,
      ),
      itemCount: AppConstants.emergencyTemplates.length,
      itemBuilder: (context, index) {
        final template = AppConstants.emergencyTemplates[index];
        final isSelected = _selectedTemplate == template;

        return FadeInUp(
          delay: Duration(milliseconds: 200 + (index * 50)),
          child: GlassCard(
            showGlow: isSelected,
            onTap: () {
              setState(() {
                _selectedTemplate = template;
                _messageController.text = template;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getTemplateIcon(template),
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  size: 32,
                ),
                const SizedBox(height: AppTheme.spaceS),
                Text(
                  template,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getTemplateIcon(String template) {
    switch (template) {
      case 'Need Help':
        return Icons.help;
      case 'Medical Emergency':
        return Icons.medical_services;
      case 'Food Required':
        return Icons.restaurant;
      case 'Water Needed':
        return Icons.water_drop;
      case 'Rescue Required':
        return Icons.sos;
      case 'Safe Location':
        return Icons.shield;
      default:
        return Icons.campaign;
    }
  }

  bool _canSend(MeshProvider provider) {
    return provider.isMeshActive && _messageController.text.trim().isNotEmpty;
  }

  void _sendBroadcast(MeshProvider provider) {
    final message = _messageController.text.trim();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.warningColor),
            const SizedBox(width: AppTheme.spaceS),
            const Text('Send Broadcast?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are about to send:',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.spaceS),
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Text(
              'This will be sent to ${provider.connectedNodesCount} connected nodes',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.sendMessage(
                to: 'broadcast',
                content: message,
                isBroadcast: true,
              );

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Broadcast sent to ${provider.connectedNodesCount} nodes',
                  ),
                  backgroundColor: AppTheme.successColor,
                ),
              );

              setState(() {
                _messageController.clear();
                _selectedTemplate = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Send Broadcast'),
          ),
        ],
      ),
    );
  }
}
