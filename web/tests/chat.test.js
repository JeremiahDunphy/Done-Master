import { jest } from '@jest/globals';

// Mock Socket.io globally
const mockSocket = {
    connect: jest.fn(),
    disconnect: jest.fn(),
    on: jest.fn(),
    emit: jest.fn(),
    close: jest.fn()
};
global.io = jest.fn(() => mockSocket);

// Mock router.js using unstable_mockModule
jest.unstable_mockModule('../js/shared/router.js', () => ({
    showPage: jest.fn(),
    updateNavbar: jest.fn()
}));

// Dynamic imports
const { chatService } = await import('../js/features/chat/chat.service.js');
const chatUi = await import('../js/features/chat/chat.ui.js');
const { state } = await import('../js/shared/state.js');
const { showPage } = await import('../js/shared/router.js');

describe('Chat Feature', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        document.body.innerHTML = `
            <nav id="navbar" class="hidden">
                <div id="user-info"></div>
            </nav>
            <div id="app"></div>
            <div id="conversations-container"></div>
            <div id="messages-container"></div>
            <div id="chat-user-name"></div>
            <form id="chat-form">
                <input id="message-input" />
                <button type="submit">Send</button>
            </form>
        `;
        state.currentUser = { id: 1, name: 'Test User' };
    });

    describe('ChatService', () => {
        test('connect should initialize socket if user is logged in', () => {
            chatService.socket = null; // Reset
            chatService.connect();
            expect(global.io).toHaveBeenCalledWith('http://localhost:3000', expect.any(Object));
            expect(mockSocket.connect).toHaveBeenCalled();
            expect(mockSocket.on).toHaveBeenCalledWith('connect', expect.any(Function));
            expect(mockSocket.on).toHaveBeenCalledWith('receive_message', expect.any(Function));
        });

        test('connect should not initialize socket if user is not logged in', () => {
            state.currentUser = null;
            chatService.socket = null;
            chatService.connect();
            expect(global.io).not.toHaveBeenCalled();
        });

        test('sendMessage should emit send_message event', () => {
            chatService.socket = mockSocket;
            chatService.sendMessage(2, 'Hello');
            expect(mockSocket.emit).toHaveBeenCalledWith('send_message', {
                senderId: 1,
                receiverId: 2,
                content: 'Hello'
            });
        });

        test('disconnect should disconnect socket', () => {
            chatService.socket = mockSocket;
            chatService.disconnect();
            expect(mockSocket.disconnect).toHaveBeenCalled();
            expect(chatService.socket).toBeNull();
        });
    });

    describe('Chat UI', () => {
        beforeEach(() => {
            // Ensure socket is mocked and connected for UI tests
            chatService.socket = mockSocket;
        });

        test('loadConversations should render conversations', async () => {
            const mockConversations = [
                {
                    user: { id: 2, name: 'Other User', profileImage: 'img.jpg' },
                    lastMessage: 'Hi',
                    timestamp: new Date().toISOString()
                }
            ];
            global.fetch.mockImplementation((url) => {
                if (url.includes('/conversations/')) {
                    return Promise.resolve({
                        ok: true,
                        json: async () => mockConversations
                    });
                }
                return Promise.resolve({ ok: false });
            });

            await chatUi.loadConversations();

            const container = document.getElementById('conversations-container');
            expect(container.children.length).toBe(1);
            expect(container.textContent).toContain('Other User');
            expect(container.textContent).toContain('Hi');
        });

        test('startChatWith should show chat page and load messages', async () => {
            const user = { id: 2, name: 'Other User' };
            const mockMessages = [
                { id: 1, senderId: 2, content: 'Hello', createdAt: new Date().toISOString() }
            ];

            global.fetch.mockImplementation((url) => {
                if (url.includes('/messages/')) {
                    return Promise.resolve({
                        ok: true,
                        json: async () => mockMessages
                    });
                }
                if (url.includes('/conversations/')) {
                    return Promise.resolve({
                        ok: true,
                        json: async () => []
                    });
                }
                return Promise.resolve({ ok: false });
            });

            await chatUi.startChatWith(user);

            expect(showPage).toHaveBeenCalledWith('chat');
            expect(document.getElementById('chat-user-name').textContent).toBe('Other User');

            // Wait for async operations
            await new Promise(resolve => setTimeout(resolve, 0));

            const container = document.getElementById('messages-container');
            expect(container.children.length).toBe(1);
            expect(container.textContent).toContain('Hello');
        });

        test('sending a message should call chatService.sendMessage', async () => {
            const user = { id: 2, name: 'Other User' };

            global.fetch.mockImplementation(() => Promise.resolve({ ok: true, json: async () => [] }));

            await chatUi.startChatWith(user);

            const input = document.getElementById('message-input');
            input.value = 'New Message';

            const form = document.getElementById('chat-form');
            form.dispatchEvent(new Event('submit'));

            expect(mockSocket.emit).toHaveBeenCalledWith('send_message', {
                senderId: 1,
                receiverId: 2,
                content: 'New Message'
            });
            expect(input.value).toBe('');
        });
    });
});
