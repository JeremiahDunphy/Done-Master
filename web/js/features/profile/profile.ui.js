import { state, saveUser } from '../../shared/state.js';
import { API_BASE_URL } from '../../shared/config.js';
import { showMessage } from '../../shared/utils.js';
import { uploadPhoto } from '../../shared/api.js';

let newProfileImageUrl = null;

export function loadProfile() {
    console.log('loadProfile called, currentUser:', state.currentUser);
    if (!state.currentUser) return;

    document.getElementById('profile-name').textContent = state.currentUser.name || 'User';
    document.getElementById('profile-email').textContent = state.currentUser.email;
    document.getElementById('profile-role').textContent = state.currentUser.role;

    document.getElementById('profile-bio').value = state.currentUser.bio || '';
    document.getElementById('profile-skills').value = state.currentUser.skills || '';

    const rateInput = document.getElementById('profile-rate');
    const rateContainer = rateInput.closest('.form-group'); // Assuming it's in a form-group
    console.log('Role:', state.currentUser.role, 'Rate Container:', rateContainer);
    if (state.currentUser.role === 'DOER') {
        if (rateContainer) rateContainer.style.display = 'block';
        rateInput.value = state.currentUser.hourlyRate || '';
    } else { // POSTER
        if (rateContainer) rateContainer.style.display = 'none';
    }

    if (state.currentUser.profileImage) {
        const img = document.getElementById('profile-image-display');
        img.src = state.currentUser.profileImage;
        img.style.display = 'block';
        document.getElementById('profile-initials').style.display = 'none';
    }

    // Done Pro Badge
    const badgesContainer = document.getElementById('profile-badges');
    if (state.currentUser.isElite) {
        badgesContainer.innerHTML = `
            <div class="badge" style="background: #fbbf24; color: #000; display: flex; align-items: center; gap: 0.25rem;">
                <span>✓</span> Done Pro
            </div>
        `;
    } else {
        badgesContainer.innerHTML = '';
    }

    return loadUserReviews(state.currentUser.id);
}

import { getUserReviews } from '../reviews/reviews.service.js';

export async function loadUserReviews(userId) {
    try {
        const reviews = await getUserReviews(userId);

        // Calculate average
        const avg = reviews.length ? (reviews.reduce((a, b) => a + b.rating, 0) / reviews.length).toFixed(1) : 'New';

        // Add reviews section if not exists
        let reviewsSection = document.getElementById('profile-reviews');
        if (!reviewsSection) {
            reviewsSection = document.createElement('div');
            reviewsSection.id = 'profile-reviews';
            reviewsSection.style.marginTop = '2rem';
            reviewsSection.style.borderTop = '1px solid var(--border-light)';
            reviewsSection.style.paddingTop = '1rem';
            document.querySelector('#profile-page .card').appendChild(reviewsSection);
        }

        reviewsSection.innerHTML = `
            <h3>Reviews (${avg} ★)</h3>
            <div style="display: flex; flex-direction: column; gap: 1rem; margin-top: 1rem;">
                ${reviews.length === 0 ? '<p class="text-muted">No reviews yet.</p>' : ''}
                ${reviews.map(r => `
                    <div style="background: var(--bg-secondary); padding: 1rem; border-radius: 0.5rem;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 0.5rem;">
                            <strong>${r.reviewer.name || 'User'}</strong>
                            <span style="color: var(--secondary);">${'★'.repeat(r.rating)}${'☆'.repeat(5 - r.rating)}</span>
                        </div>
                        <p>${r.comment}</p>
                    </div>
                `).join('')}
            </div>
        `;
    } catch (e) {
        console.error('Failed to load reviews', e);
    }
}

export function initProfile() {
    // Expose upload handler
    window.handleProfileImageUpload = async (input) => {
        const file = input.files[0];
        if (!file) return;

        try {
            const url = await uploadPhoto(file);
            newProfileImageUrl = url;

            const img = document.getElementById('profile-image-display');
            img.src = url;
            img.style.display = 'block';
            document.getElementById('profile-initials').style.display = 'none';
        } catch (error) {
            showMessage('Failed to upload image');
        }
    };

    document.getElementById('profile-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        if (!state.currentUser) return;

        const bio = document.getElementById('profile-bio').value;
        const skills = document.getElementById('profile-skills').value;
        const hourlyRate = document.getElementById('profile-rate').value;

        try {
            const response = await fetch(`${API_BASE_URL}/users/${state.currentUser.id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    bio,
                    skills,
                    hourlyRate,
                    profileImage: newProfileImageUrl || state.currentUser.profileImage
                })
            });

            if (response.ok) {
                const updatedUser = await response.json();
                saveUser(updatedUser);
                showMessage('Profile updated successfully!');
                loadProfile();
            } else {
                showMessage('Failed to update profile');
            }
        } catch (error) {
            console.error(error);
            showMessage('Error updating profile');
        }
    });
}
