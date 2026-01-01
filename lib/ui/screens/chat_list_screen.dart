import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../../providers/mesh_provider.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Chat list
              Expanded(
                child: Consumer<MeshProvider>(
                  builder: (context, provider, child) {
                    final chats = provider.getChatList();

                    if (chats.isEmpty) {
                      return _buildEmptyState(context);
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AppTheme.spaceL),
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index];
                        return FadeInLeft(
                          delay: Duration(milliseconds: index * 50),
                          child: _buildChatCard(context, chat),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FadeInUp(
        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/discovery');
          },
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                'Messages',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppTheme.spaceXS),
              Consumer<MeshProvider>(
                builder: (context, provider, child) {
                  return Text(
                    '${provider.connectedNodesCount} nodes online',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  );
                },
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, Map<String, dynamic> chat) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(chat['timestamp']);
    final timeStr = _formatTime(timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceM),
      child: GlassCard(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: {'userId': chat['userId'], 'username': chat['username']},
          );
        },
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: Center(
                child: Text(
                  chat['username'][0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: AppTheme.spaceM),

            // Chat info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['username'],
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceXS),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat['lastMessage'],
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat['unreadCount'] > 0)
                        Container(
                          margin: const EdgeInsets.only(left: AppTheme.spaceS),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${chat['unreadCount']}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 100,
              color: AppTheme.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spaceL),
            Text(
              'No messages yet',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: AppTheme.textTertiary),
            ),
            const SizedBox(height: AppTheme.spaceS),
            Text(
              'Discover nearby nodes to start chatting',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays == 0) {
      return DateFormat.jm().format(time);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(time);
    } else {
      return DateFormat.MMMd().format(time);
    }
  }
}
