import { apiCall } from '../../shared/api.js';
import { state } from '../../shared/state.js';

export async function getNotifications() {
    if (!state.currentUser) return [];
    return await apiCall(`/notifications/${state.currentUser.id}`);
}

export async function markAsRead(notificationId) {
    return await apiCall(`/notifications/${notificationId}/read`, {
        method: 'POST'
    });
}
