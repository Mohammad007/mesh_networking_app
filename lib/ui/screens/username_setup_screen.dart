import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/primary_button.dart';
import '../../data/local_db/database_service.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _deviceId;
  late String _nodeId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    const uuid = Uuid();
    _deviceId = uuid.v4().substring(0, 8);
    _nodeId = 'MN-${_deviceId.substring(0, 6).toUpperCase()}';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _setupIdentity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Save username and device ID
    await DatabaseService.saveSetting('username', _usernameController.text);
    await DatabaseService.saveSetting('device_id', _deviceId);
    await DatabaseService.saveSetting('node_id', _nodeId);

    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),

                  // Title
                  FadeInDown(
                    child: Text(
                      'Identify Setup',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceS),

                  FadeInDown(
                    delay: const Duration(milliseconds: 100),
                    child: Text(
                      'Create your mesh node identity',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceXL),

                  // Display Name Field
                  FadeInLeft(
                    delay: const Duration(milliseconds: 200),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spaceS),
                              Text(
                                'Display Name',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceM),
                          TextFormField(
                            controller: _usernameController,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'e.g., CyberKnight2077',
                              filled: true,
                              fillColor: AppTheme.surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(AppTheme.radiusMedium),
                                ),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a username';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceM),

                  // Device ID Card
                  FadeInLeft(
                    delay: const Duration(milliseconds: 300),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.phonelink,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: AppTheme.spaceS),
                              Text(
                                'Your Unique Node ID',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceM),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppTheme.spaceM),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMedium,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.tag,
                                  color: AppTheme.accentColor,
                                  size: 16,
                                ),
                                const SizedBox(width: AppTheme.spaceS),
                                Text(
                                  _nodeId,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        color: AppTheme.accentColor,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceM),

                  // Info
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spaceM),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withOpacity(0.1),
                        border: Border.all(
                          color: AppTheme.infoColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusMedium,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.infoColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spaceS),
                          Expanded(
                            child: Text(
                              'This ID is used to identify your device in the mesh network',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Continue Button
                  FadeInUp(
                    delay: const Duration(milliseconds: 500),
                    child: PrimaryButton(
                      text: 'Initialize Node →',
                      onPressed: _isLoading ? null : _setupIdentity,
                      isLoading: _isLoading,
                      icon: Icons.rocket_launch,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceM),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
