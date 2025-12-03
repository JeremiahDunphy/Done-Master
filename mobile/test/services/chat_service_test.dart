import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile/shared/services/chat_service.dart';
import 'package:mobile/shared/models/models.dart';

import 'chat_service_test.mocks.dart';

@GenerateMocks([], customMocks: [MockSpec<IO.Socket>(as: #MockSocket)])
void main() {
  late ChatService chatService;
  late MockSocket mockSocket;

  setUp(() {
    mockSocket = MockSocket();
    chatService = ChatService(socket: mockSocket);
    
    // Common stubs
    when(mockSocket.connect()).thenReturn(mockSocket);
    when(mockSocket.disconnect()).thenReturn(mockSocket);
    when(mockSocket.dispose()).thenReturn(null);
    when(mockSocket.emit(any, any)).thenReturn(null);
    
    // Stub on('connect')
    when(mockSocket.on('connect', any)).thenAnswer((invocation) {
      final callback = invocation.positionalArguments[1] as Function(dynamic);
      callback(null);
      return () {};
    });

    // Stub on('receive_message')
    when(mockSocket.on('receive_message', any)).thenReturn(() {});
  });

  group('ChatService', () {
    test('connect calls socket.connect and emits join_room', () {
      // Stubs are in setUp

      chatService.connect(1);

      verify(mockSocket.connect()).called(1);
      verify(mockSocket.on('connect', any)).called(1);
      verify(mockSocket.emit('join_room', 1)).called(1);
    });

    test('sendMessage emits send_message', () {
      chatService.sendMessage(1, 2, 'Hello');

      verify(mockSocket.emit('send_message', {
        'senderId': 1,
        'receiverId': 2,
        'content': 'Hello',
      })).called(1);
    });

    test('disconnect calls socket.disconnect', () {
      chatService.disconnect();
      verify(mockSocket.disconnect()).called(1);
    });

    test('dispose calls socket.dispose', () {
      chatService.dispose();
      verify(mockSocket.dispose()).called(1);
    });

    test('receive_message adds message to stream', () async {
      // Capture the listener
      Function(dynamic)? listener;
      when(mockSocket.on('receive_message', any)).thenAnswer((invocation) {
        listener = invocation.positionalArguments[1] as Function(dynamic);
        return () {};
      });

      chatService.connect(1);

      expect(listener, isNotNull);

      // Simulate receiving a message
      final messageJson = {
        'id': 1,
        'senderId': 2,
        'receiverId': 1,
        'content': 'Hello',
        'createdAt': DateTime.now().toIso8601String(),
        'sender': {'id': 2, 'name': 'Sender'},
        'receiver': {'id': 1, 'name': 'Receiver'}
      };

      expectLater(chatService.messageStream, emits(isA<Message>()));

      listener!(messageJson);
    });
  });
}
