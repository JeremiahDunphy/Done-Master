import { jest } from '@jest/globals';
import { chatService } from '../js/features/chat/chat.service.js';
import { state } from '../js/shared/state.js';

// Mock socket.io
const mockSocket = {
    connect: jest.fn(),
    disconnect: jest.fn(),
    emit: jest.fn(),
    on: jest.fn(),
};

global.io = jest.fn(() => mockSocket);

describe('ChatService', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        state.currentUser = { id: 1, name: 'Test User' };
        chatService.socket = null; // Reset socket
    });

    test('connect initializes socket and joins room', () => {
        chatService.connect();

        expect(global.io).toHaveBeenCalledWith('http://localhost:3000', expect.any(Object));
        expect(mockSocket.connect).toHaveBeenCalled();

        // Simulate connect event
        const connectCallback = mockSocket.on.mock.calls.find(call => call[0] === 'connect')[1];
        connectCallback();

        expect(mockSocket.emit).toHaveBeenCalledWith('join_room', 1);
    });

    test('sendMessage emits event', () => {
        chatService.connect();
        chatService.sendMessage(2, 'Hello');

        expect(mockSocket.emit).toHaveBeenCalledWith('send_message', {
            senderId: 1,
            receiverId: 2,
            content: 'Hello'
        });
    });

    test('getConversations fetches from API', async () => {
        global.fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => [{ id: 1, lastMessage: 'Hi' }]
        });

        const conversations = await chatService.getConversations();

        expect(global.fetch).toHaveBeenCalledWith('http://localhost:3000/conversations/1');
        expect(conversations).toHaveLength(1);
    });
});
