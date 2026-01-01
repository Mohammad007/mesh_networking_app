import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../../providers/mesh_provider.dart';
import '../../data/models/user_model.dart';

class NetworkMapScreen extends StatefulWidget {
  const NetworkMapScreen({super.key});

  @override
  State<NetworkMapScreen> createState() => _NetworkMapScreenState();
}

class _NetworkMapScreenState extends State<NetworkMapScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
              _buildHeader(provider),

              // Network Visualization
              Expanded(
                child: Stack(
                  children: [
                    // Center node (current user)
                    Center(
                      child: FadeInDown(child: _buildCenterNode(provider)),
                    ),

                    // Connected nodes in a circle
                    if (provider.connectedNodes.isNotEmpty)
                      ..._buildConnectedNodes(provider),

                    // Legend
                    Positioned(
                      bottom: AppTheme.spaceL,
                      left: AppTheme.spaceL,
                      right: AppTheme.spaceL,
                      child: FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: _buildLegend(provider),
                      ),
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

  Widget _buildHeader(MeshProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceL),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: AppTheme.spaceM),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network Topology',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Text(
                    'Live mesh network visualization',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceM,
                  vertical: AppTheme.spaceS,
                ),
                decoration: BoxDecoration(
                  color: provider.isMeshActive
                      ? AppTheme.successColor.withOpacity(0.2)
                      : AppTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider.isMeshActive
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceS),
                    Text(
                      provider.isMeshActive ? 'Active' : 'Offline',
                      style: TextStyle(
                        color: provider.isMeshActive
                            ? AppTheme.successColor
                            : AppTheme.errorColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCenterNode(MeshProvider provider) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(
                  0.3 +
                      (0.2 *
                          math.sin(_animationController.value * 2 * math.pi)),
                ),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, color: Colors.black, size: 32),
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                provider.currentUsername ?? 'You',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildConnectedNodes(MeshProvider provider) {
    final nodes = provider.connectedNodes.values.toList();
    final widgets = <Widget>[];

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      final angle = (2 * math.pi / nodes.length) * i;
      final radius = 150.0;

      widgets.add(
        _buildNodeWithConnection(
          node: node,
          angle: angle,
          radius: radius,
          index: i,
        ),
      );
    }

    return widgets;
  }

  Widget _buildNodeWithConnection({
    required UserModel node,
    required double angle,
    required double radius,
    required int index,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Connection line
            CustomPaint(
              size: Size.infinite,
              painter: ConnectionLinePainter(
                angle: angle,
                radius: radius,
                opacity:
                    0.3 +
                    (0.2 * math.sin(_animationController.value * 2 * math.pi)),
              ),
            ),

            // Node
            Positioned(
              left:
                  MediaQuery.of(context).size.width / 2 +
                  math.cos(angle) * radius -
                  30,
              top:
                  MediaQuery.of(context).size.height / 2 +
                  math.sin(angle) * radius -
                  30,
              child: FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: GestureDetector(
                  onTap: () => _showNodeDetails(node),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.surfaceColor,
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.router,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          node.username.substring(
                            0,
                            math.min(4, node.username.length),
                          ),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegend(MeshProvider provider) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLegendItem(
                'Total Nodes',
                '${provider.connectedNodesCount + 1}',
                AppTheme.primaryColor,
              ),
              _buildLegendItem(
                'Active Connections',
                '${provider.connectedNodesCount}',
                AppTheme.successColor,
              ),
              _buildLegendItem(
                'Messages',
                '${provider.pendingMessagesCount}',
                AppTheme.warningColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spaceXS),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showNodeDetails(UserModel node) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spaceL),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  node.username[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceM),
            Text(
              node.username,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              node.deviceId,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.primaryColor),
            ),
            const SizedBox(height: AppTheme.spaceL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Signal', '${node.signalStrength ?? '?'} dBm'),
                _buildDetailItem('Distance', node.distanceText),
                _buildDetailItem('Status', node.status),
              ],
            ),
            const SizedBox(height: AppTheme.spaceL),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/chat',
                        arguments: {
                          'userId': node.id,
                          'username': node.username,
                        },
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Message'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
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
}

// Custom painter for connection lines
class ConnectionLinePainter extends CustomPainter {
  final double angle;
  final double radius;
  final double opacity;

  ConnectionLinePainter({
    required this.angle,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryColor.withOpacity(opacity)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final end = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(ConnectionLinePainter oldDelegate) => true;
}
