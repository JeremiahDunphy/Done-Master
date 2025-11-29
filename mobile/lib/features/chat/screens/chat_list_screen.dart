import 'package:flutter/material.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/api_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final ApiService apiService;

  const ChatListScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<Conversation>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversationsFuture = widget.apiService.getConversations(widget.apiService.user!.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: FutureBuilder<List<Conversation>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          final conversations = snapshot.data!;
          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: conversation.user.profileImage != null && conversation.user.profileImage!.isNotEmpty
                      ? NetworkImage(conversation.user.profileImage!) // In real app, handle full URL
                      : null,
                  child: conversation.user.profileImage == null || conversation.user.profileImage!.isEmpty
                      ? Text(conversation.user.name[0])
                      : null,
                ),
                title: Text(conversation.user.name),
                subtitle: Text(
                  conversation.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  _formatDate(conversation.timestamp),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        apiService: widget.apiService,
                        otherUser: conversation.user,
                      ),
                    ),
                  ).then((_) => _loadConversations());
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.month}/${date.day}';
  }
}
