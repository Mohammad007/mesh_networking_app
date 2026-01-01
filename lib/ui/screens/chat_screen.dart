import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../providers/mesh_provider.dart';
import '../../data/models/message_model.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String username;

  const ChatScreen({super.key, required this.userId, required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MeshProvider>();
    final messages = provider.getMessagesForUser(widget.userId);

    // Scroll to bottom when messages change
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(provider),

              // Messages
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppTheme.spaceL),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return FadeInUp(
                            duration: const Duration(milliseconds: 200),
                            child: _buildMessageBubble(message, provider),
                          );
                        },
                      ),
              ),

              // Message Input
              _buildMessageInput(provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(MeshProvider provider) {
    final isOnline = provider.connectedNodes.containsKey(widget.userId);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceL),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),

          const SizedBox(width: AppTheme.spaceM),

          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Text(
                widget.username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spaceM),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.username,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spaceXS),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOnline
                            ? AppTheme.successColor
                            : AppTheme.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceXS),
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOnline
                            ? AppTheme.successColor
                            : AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // More options
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onPressed: () {
              _showMoreOptions();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message, MeshProvider provider) {
    final isSentByMe = message.from == provider.currentUserId;
    final timestamp = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final timeStr = DateFormat.jm().format(timestamp);

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spaceM),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceM,
                vertical: AppTheme.spaceS,
              ),
              decoration: BoxDecoration(
                gradient: isSentByMe
                    ? AppTheme.primaryGradient
                    : LinearGradient(
                        colors: [
                          AppTheme.surfaceColor,
                          AppTheme.surfaceColor.withOpacity(0.8),
                        ],
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radiusMedium),
                  topRight: const Radius.circular(AppTheme.radiusMedium),
                  bottomLeft: Radius.circular(
                    isSentByMe ? AppTheme.radiusMedium : AppTheme.radiusSmall,
                  ),
                  bottomRight: Radius.circular(
                    isSentByMe ? AppTheme.radiusSmall : AppTheme.radiusMedium,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isSentByMe ? AppTheme.primaryColor : Colors.black)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    message.payload,
                    style: TextStyle(
                      color: isSentByMe ? Colors.black : AppTheme.textPrimary,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceXS),

                  // Time and status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: isSentByMe
                              ? Colors.black54
                              : AppTheme.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const SizedBox(width: AppTheme.spaceXS),
                        Icon(
                          message.status == 'delivered' ||
                                  message.status == 'relayed'
                              ? Icons.done_all
                              : Icons.done,
                          size: 14,
                          color:
                              message.status == 'delivered' ||
                                  message.status == 'relayed'
                              ? Colors.blue
                              : Colors.black54,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Relay info (if relayed)
            if (message.hop > 0) ...[
              const SizedBox(height: AppTheme.spaceXS),
              Text(
                'Relayed via ${message.hop} node${message.hop > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spaceL),
            Text(
              'No messages yet',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textTertiary),
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              'Send a message to start the conversation',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(MeshProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceL),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji button (placeholder)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined, size: 20),
              color: AppTheme.primaryColor,
              onPressed: () {
                // Show emoji picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Emoji picker coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: AppTheme.spaceM),

          // Text input
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceM,
                vertical: AppTheme.spaceXS,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppTheme.textTertiary),
                  border: InputBorder.none,
                  isDense: true,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spaceM),

          // Send button
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.glowShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () => _sendMessage(provider),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(MeshProvider provider) async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    if (!provider.isMeshActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please turn on mesh network first'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Send message
    await provider.sendMessage(
      to: widget.userId,
      content: text,
      isBroadcast: false,
    );

    // Clear input
    _messageController.clear();

    // Scroll to bottom
    _scrollToBottom();

    // Haptic feedback
    // HapticFeedback.lightImpact();
  }

  void _showMoreOptions() {
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
            ListTile(
              leading: Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                _showUserProfile();
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: AppTheme.errorColor),
              title: const Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Block feature coming soon')),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: AppTheme.warningColor),
              title: const Text('Clear Chat'),
              onTap: () {
                Navigator.pop(context);
                _showClearChatDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserProfile() {
    final provider = context.read<MeshProvider>();
    final user = provider.connectedNodes[widget.userId];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: Text(widget.username),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileItem('User ID', widget.userId),
            if (user != null) ...[
              _buildProfileItem('Signal', '${user.signalStrength ?? '?'} dBm'),
              _buildProfileItem('Distance', user.distanceText),
              _buildProfileItem('Status', user.status),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Clear Chat?'),
        content: const Text(
          'This will delete all messages with this user. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear chat feature coming soon')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
