import { getNotifications, markAsRead } from './notifications.service.js';
import { state } from '../../shared/state.js';

export async function initNotifications() {
    if (!state.currentUser) return;

    const navLinks = document.querySelector('.nav-links');

    // Create Notification Bell
    const bellContainer = document.createElement('div');
    bellContainer.style.position = 'relative';
    bellContainer.style.cursor = 'pointer';
    bellContainer.innerHTML = `
        <span style="font-size: 1.2rem;">🔔</span>
        <span id="notification-badge" style="
            position: absolute; top: -5px; right: -5px;
            background: red; color: white; font-size: 0.7rem;
            padding: 2px 5px; border-radius: 50%; display: none;
        ">0</span>
        <div id="notification-dropdown" class="card" style="
            position: absolute; top: 30px; right: 0; width: 300px;
            display: none; z-index: 1000; max-height: 400px; overflow-y: auto;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        ">
            <p class="text-center text-muted p-sm">Loading...</p>
        </div>
    `;

    // Insert before profile link (last item)
    navLinks.insertBefore(bellContainer, navLinks.lastElementChild);

    // Toggle Dropdown
    bellContainer.onclick = async (e) => {
        if (e.target.closest('#notification-dropdown')) return;

        const dropdown = document.getElementById('notification-dropdown');
        const isVisible = dropdown.style.display === 'block';
        dropdown.style.display = isVisible ? 'none' : 'block';

        if (!isVisible) {
            await loadNotifications();
        }
    };

    // Initial Load
    await updateBadge();

    // Poll every 30 seconds
    setInterval(updateBadge, 30000);
}

async function updateBadge() {
    try {
        const notifications = await getNotifications();
        const unreadCount = notifications.filter(n => !n.read).length;
        const badge = document.getElementById('notification-badge');

        if (unreadCount > 0) {
            badge.textContent = unreadCount;
            badge.style.display = 'block';
        } else {
            badge.style.display = 'none';
        }
    } catch (e) {
        console.error('Failed to update notifications badge');
    }
}

async function loadNotifications() {
    const dropdown = document.getElementById('notification-dropdown');
    try {
        const notifications = await getNotifications();

        if (notifications.length === 0) {
            dropdown.innerHTML = '<p class="text-center text-muted p-sm">No notifications</p>';
            return;
        }

        dropdown.innerHTML = notifications.map(n => `
            <div class="notification-item ${n.read ? '' : 'unread'}" style="
                padding: 0.75rem; border-bottom: 1px solid var(--border-light);
                background: ${n.read ? 'transparent' : 'var(--bg-secondary)'};
                cursor: pointer;
            " onclick="window.handleNotificationClick(${n.id})">
                <p style="margin: 0; font-size: 0.9rem;">${n.message}</p>
                <span style="font-size: 0.7rem; color: var(--text-muted);">${new Date(n.createdAt).toLocaleDateString()}</span>
            </div>
        `).join('');

    } catch (e) {
        dropdown.innerHTML = '<p class="text-center text-muted p-sm">Failed to load</p>';
    }
}

window.handleNotificationClick = async (id) => {
    await markAsRead(id);
    await updateBadge();
    await loadNotifications(); // Refresh list to remove unread styling
};
