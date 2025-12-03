import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/models.dart';

class ChatService {
  IO.Socket? _socket;
  final _messageController = StreamController<Message>.broadcast();

  ChatService({IO.Socket? socket}) : _socket = socket;

  Stream<Message> get messageStream => _messageController.stream;

  void connect(int userId) {
    _socket ??= IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    
    final socket = _socket!;
    
    socket.connect();
    
    socket.onConnect((_) {
      print('Connected to socket');
      socket.emit('join_room', userId);
    });

    socket.on('receive_message', (data) {
      try {
        final message = Message.fromJson(data);
        _messageController.add(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
  }

  void sendMessage(int senderId, int receiverId, String content) {
    _socket?.emit('send_message', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }
  
  void disconnect() {
    _socket?.disconnect();
  }
  
  void dispose() {
    _messageController.close();
    _socket?.dispose();
  }
}
