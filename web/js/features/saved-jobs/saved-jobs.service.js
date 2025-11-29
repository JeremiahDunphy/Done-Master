import { apiCall } from '../../shared/api.js';
import { state } from '../../shared/state.js';

export async function toggleSavedJob(jobId) {
    return await apiCall('/saved-jobs', {
        method: 'POST',
        body: JSON.stringify({ userId: state.currentUser.id, jobId }),
    });
}

export async function getSavedJobIds() {
    if (!state.currentUser) return [];
    return await apiCall(`/saved-jobs/${state.currentUser.id}`);
}
