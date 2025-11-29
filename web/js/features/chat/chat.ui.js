import { chatService } from './chat.service.js';
import { state } from '../../shared/state.js';
import { showPage } from '../../shared/router.js';

let activeConversationUserId = null;

export function initChat() {
    chatService.connect();

    chatService.on('receive_message', (message) => {
        // If we are viewing this conversation, append message
        if (activeConversationUserId &&
            (message.senderId === activeConversationUserId || message.senderId === state.currentUser.id)) {
            appendMessage(message);
        }
        // Refresh conversation list to show latest message/unread status
        loadConversations();
    });

    // Initial load
    loadConversations();
}

export async function loadConversations() {
    const container = document.getElementById('conversations-container');
    if (!container) return;

    try {
        const conversations = await chatService.getConversations();
        container.innerHTML = conversations.length ? '' : '<p class="text-muted" style="padding: 1rem;">No messages yet</p>';

        conversations.forEach(conv => {
            const div = document.createElement('div');
            div.className = 'conversation-item';
            div.style.padding = '1rem';
            div.style.borderBottom = '1px solid var(--border-light)';
            div.style.cursor = 'pointer';
            div.style.background = activeConversationUserId === conv.user.id ? 'rgba(255, 77, 77, 0.1)' : 'transparent';

            div.innerHTML = `
                <div style="display: flex; gap: 0.75rem; align-items: center;">
                    <div style="width: 40px; height: 40px; background: var(--bg-tertiary); border-radius: 50%; display: flex; align-items: center; justify-content: center; overflow: hidden;">
                        ${conv.user.profileImage ? `<img src="${conv.user.profileImage}" style="width: 100%; height: 100%; object-fit: cover;">` : conv.user.name[0]}
                    </div>
                    <div style="flex: 1; min-width: 0;">
                        <div style="display: flex; justify-content: space-between;">
                            <h4 style="margin: 0; font-size: 0.9rem;">${conv.user.name}</h4>
                            <span style="font-size: 0.75rem; color: var(--text-muted);">${formatTime(conv.timestamp)}</span>
                        </div>
                        <p style="margin: 0.25rem 0 0; font-size: 0.85rem; color: var(--text-muted); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${conv.lastMessage}
                        </p>
                    </div>
                </div>
            `;

            div.onclick = () => startChatWith(conv.user);
            container.appendChild(div);
        });
    } catch (e) {
        console.error('Failed to load conversations', e);
    }
}

export async function startChatWith(user) {
    showPage('chat');
    activeConversationUserId = user.id;
    document.getElementById('chat-user-name').textContent = user.name;
    document.getElementById('message-input').disabled = false;
    document.querySelector('#chat-form button').disabled = false;

    // Highlight active conversation
    loadConversations();

    const container = document.getElementById('messages-container');
    container.innerHTML = '<div class="spinner" style="margin: auto;"></div>';

    try {
        const messages = await chatService.getMessages(user.id);
        container.innerHTML = '';
        messages.forEach(appendMessage);
        scrollToBottom();
    } catch (e) {
        container.innerHTML = '<p class="text-error">Failed to load messages</p>';
    }

    // Setup form submit
    const form = document.getElementById('chat-form');
    form.onsubmit = (e) => {
        e.preventDefault();
        const input = document.getElementById('message-input');
        const content = input.value.trim();
        if (!content) return;

        chatService.sendMessage(user.id, content);

        // Optimistic append
        /*
        appendMessage({
            id: Date.now(),
            content: content,
            senderId: state.currentUser.id,
            createdAt: new Date().toISOString()
        });
        */

        input.value = '';
    };
}

function appendMessage(message) {
    const container = document.getElementById('messages-container');
    const isMe = message.senderId === state.currentUser.id;

    const div = document.createElement('div');
    div.style.alignSelf = isMe ? 'flex-end' : 'flex-start';
    div.style.maxWidth = '70%';
    div.style.padding = '0.75rem 1rem';
    div.style.borderRadius = '1rem';
    div.style.background = isMe ? 'var(--primary)' : 'var(--bg-tertiary)';
    div.style.color = isMe ? 'white' : 'var(--text-primary)';
    div.style.borderBottomRightRadius = isMe ? '0.25rem' : '1rem';
    div.style.borderBottomLeftRadius = isMe ? '1rem' : '0.25rem';

    div.textContent = message.content;

    container.appendChild(div);
    scrollToBottom();
}

function scrollToBottom() {
    const container = document.getElementById('messages-container');
    container.scrollTop = container.scrollHeight;
}

function formatTime(isoString) {
    const date = new Date(isoString);
    const now = new Date();
    if (date.toDateString() === now.toDateString()) {
        return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    }
    return date.toLocaleDateString([], { month: 'short', day: 'numeric' });
}
