/**
 * @jest-environment jsdom
 */

// We need to test the UI logic which is in profile.ui.js
// However, profile.ui.js manipulates the DOM.
// We can test the logic by setting up the DOM and calling initProfile or loadProfile.

import { loadProfile } from '../js/features/profile/profile.ui.js';
import { state } from '../js/shared/state.js';
import { jest } from '@jest/globals';

// Mock reviews service dynamic import
jest.mock('../js/features/reviews/reviews.service.js', () => ({
    getUserReviews: jest.fn().mockResolvedValue([])
}), { virtual: true });

describe('profile.ui.js', () => {
    beforeEach(() => {
        state.currentUser = {
            id: 1,
            name: 'Test User',
            email: 'test@example.com',
            role: 'PROVIDER',
            isElite: true,
            profileImage: 'img.jpg'
        };
        document.body.innerHTML = `
      <div id="profile-page">
        <h2 id="profile-name"></h2>
        <p id="profile-email"></p>
        <span id="profile-role"></span>
        <div id="profile-badges"></div>
        <textarea id="profile-bio"></textarea>
        <input id="profile-skills" />
        <input id="profile-rate" />
        <img id="profile-image-display" />
        <span id="profile-initials"></span>
        <div class="card"></div>
      </div>
    `;
    });

    test('loadProfile displays Done Pro badge for elite users', async () => {
        // Act
        await loadProfile();

        // Assert
        const badgesContainer = document.getElementById('profile-badges');
        expect(badgesContainer.innerHTML).toContain('Done Pro');
        expect(badgesContainer.innerHTML).toContain('✓');
    });

    test('loadProfile does not display badge for non-elite users', async () => {
        // Arrange
        state.currentUser.isElite = false;

        // Act
        await loadProfile();

        // Assert
        const badgesContainer = document.getElementById('profile-badges');
        expect(badgesContainer.innerHTML).toBe('');
    });
});
