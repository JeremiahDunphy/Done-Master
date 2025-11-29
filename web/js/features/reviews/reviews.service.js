import { apiCall } from '../../shared/api.js';

export async function createReview(reviewData) {
    return await apiCall('/reviews', {
        method: 'POST',
        body: JSON.stringify(reviewData),
    });
}

export async function getUserReviews(userId) {
    return await apiCall(`/users/${userId}/reviews`);
}
