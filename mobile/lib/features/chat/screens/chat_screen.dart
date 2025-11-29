import 'package:flutter/material.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ApiService apiService;
  final User otherUser;

  const ChatScreen({
    Key? key,
    required this.apiService,
    required this.otherUser,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService _chatService;
  final TextEditingController _messageController = TextEditingController();
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(widget.apiService);
    _chatService.connect(widget.apiService.user!.id);
    _loadMessages();
    
    _chatService.messageStream.listen((message) {
      if (message.senderId == widget.otherUser.id || message.receiverId == widget.otherUser.id) {
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _chatService.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await widget.apiService.getMessages(
        widget.apiService.user!.id,
        widget.otherUser.id,
      );
      setState(() {
        _messages.addAll(messages);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      print('Failed to load messages: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final content = _messageController.text.trim();
    _chatService.sendMessage(
      widget.apiService.user!.id,
      widget.otherUser.id,
      content,
    );

    // Optimistically add message
    /*
    setState(() {
      _messages.add(Message(
        id: 0, // Temp ID
        content: content,
        senderId: widget.apiService.user!.id,
        receiverId: widget.otherUser.id,
        createdAt: DateTime.now(),
      ));
    });
    */
    // Wait for socket echo? Or just clear?
    // The server emits 'receive_message' to sender too.
    
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.otherUser.profileImage != null && widget.otherUser.profileImage!.isNotEmpty
                  ? NetworkImage(widget.otherUser.profileImage!)
                  : null,
              child: widget.otherUser.profileImage == null || widget.otherUser.profileImage!.isEmpty
                  ? Text(widget.otherUser.name[0])
                  : null,
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(widget.otherUser.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message.senderId == widget.apiService.user!.id;
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
