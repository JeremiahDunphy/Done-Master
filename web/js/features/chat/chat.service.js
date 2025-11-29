import { state } from '../../shared/state.js';

class ChatService {
    constructor() {
        this.socket = null;
        this.listeners = new Map();
    }

    connect() {
        if (this.socket) return;
        if (!state.currentUser) return;

        this.socket = io('http://localhost:3000', {
            transports: ['websocket'],
            autoConnect: false
        });

        this.socket.connect();

        this.socket.on('connect', () => {
            console.log('Connected to socket');
            this.socket.emit('join_room', state.currentUser.id);
        });

        this.socket.on('receive_message', (message) => {
            this.notifyListeners('receive_message', message);
        });
    }

    disconnect() {
        if (this.socket) {
            this.socket.disconnect();
            this.socket = null;
        }
    }

    sendMessage(receiverId, content) {
        if (!this.socket) return;
        this.socket.emit('send_message', {
            senderId: state.currentUser.id,
            receiverId: receiverId,
            content: content
        });
    }

    async getConversations() {
        if (!state.currentUser) return [];
        const response = await fetch(`http://localhost:3000/conversations/${state.currentUser.id}`);
        if (!response.ok) throw new Error('Failed to fetch conversations');
        return await response.json();
    }

    async getMessages(otherUserId) {
        if (!state.currentUser) return [];
        const response = await fetch(`http://localhost:3000/messages/${state.currentUser.id}/${otherUserId}`);
        if (!response.ok) throw new Error('Failed to fetch messages');
        return await response.json();
    }

    on(event, callback) {
        if (!this.listeners.has(event)) {
            this.listeners.set(event, []);
        }
        this.listeners.get(event).push(callback);
    }

    notifyListeners(event, data) {
        if (this.listeners.has(event)) {
            this.listeners.get(event).forEach(cb => cb(data));
        }
    }
}

export const chatService = new ChatService();
