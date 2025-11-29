import { jest } from '@jest/globals';
import { state } from '../js/shared/state.js';

// Mock dependencies
// const mockSaveUser = jest.fn(); // Using real saveUser
const mockShowMessage = jest.fn();
const mockUploadPhoto = jest.fn();
const mockGetUserReviews = jest.fn();

// Removed state mock to use real singleton

jest.unstable_mockModule('../js/shared/utils.js', () => ({
    showMessage: mockShowMessage
}));

jest.unstable_mockModule('../js/shared/api.js', () => ({
    uploadPhoto: mockUploadPhoto
}));

jest.unstable_mockModule('../js/features/reviews/reviews.service.js', () => ({
    getUserReviews: mockGetUserReviews
}));

jest.unstable_mockModule('../js/shared/config.js', () => ({
    API_BASE_URL: 'http://localhost:3000'
}));

const { loadProfile, initProfile } = await import('../js/features/profile/profile.ui.js');

describe('Profile UI', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        state.currentUser = {
            id: 1,
            name: 'Test User',
            email: 'test@example.com',
            role: 'CLIENT',
            bio: 'Bio',
            skills: 'Skills',
            hourlyRate: '50',
            profileImage: null,
            isElite: false
        };

        document.body.innerHTML = `
            <div id="profile-page">
                <div class="card">
                    <div id="profile-badges"></div>
                    <h2 id="profile-name"></h2>
                    <p id="profile-email"></p>
                    <span id="profile-role"></span>
                    <div id="profile-initials"></div>
                    <img id="profile-image-display" style="display: none;" />
                    
                    <form id="profile-form">
                        <textarea id="profile-bio"></textarea>
                        <input id="profile-skills" />
                        <input id="profile-rate" />
                        <input type="file" id="profile-image-upload" />
                        <button type="submit">Save</button>
                    </form>
                </div>
            </div>
        `;
        initProfile();
    });

    test('loadProfile populates user data', async () => {
        mockGetUserReviews.mockResolvedValue([]);
        await loadProfile();

        expect(document.getElementById('profile-name').textContent).toBe('Test User');
        expect(document.getElementById('profile-bio').value).toBe('Bio');
        expect(mockGetUserReviews).toHaveBeenCalledWith(1);
    });

    test('loadProfile displays elite badge', async () => {
        state.currentUser.isElite = true;
        mockGetUserReviews.mockResolvedValue([]);
        await loadProfile();
        expect(document.getElementById('profile-badges').innerHTML).toContain('Done Pro');
    });

    test('loadProfile loads reviews', async () => {
        mockGetUserReviews.mockResolvedValue([
            { rating: 5, comment: 'Great', reviewer: { name: 'Reviewer' } }
        ]);
        await loadProfile();

        // Wait for async DOM update
        await new Promise(process.nextTick);

        expect(document.getElementById('profile-reviews').innerHTML).toContain('Great');
        expect(document.getElementById('profile-reviews').innerHTML).toContain('5.0 ★');
    });

    test('handleProfileImageUpload uploads and updates display', async () => {
        mockUploadPhoto.mockResolvedValue('/uploads/new.jpg');

        const input = document.getElementById('profile-image-upload');
        // Mock files
        Object.defineProperty(input, 'files', {
            value: [new File([''], 'photo.jpg', { type: 'image/jpeg' })]
        });

        await window.handleProfileImageUpload(input);

        expect(mockUploadPhoto).toHaveBeenCalled();
        expect(document.getElementById('profile-image-display').src).toContain('/uploads/new.jpg');
    });

    test('profile form submission updates user', async () => {
        global.fetch.mockResolvedValueOnce({
            ok: true,
            json: async () => ({ ...state.currentUser, bio: 'Updated Bio' })
        });

        document.getElementById('profile-bio').value = 'Updated Bio';

        const form = document.getElementById('profile-form');
        form.dispatchEvent(new Event('submit'));

        await new Promise(process.nextTick);

        expect(global.fetch).toHaveBeenCalledWith(
            'http://localhost:3000/users/1',
            expect.objectContaining({
                method: 'PUT',
                body: expect.stringContaining('Updated Bio')
            })
        );
        // expect(mockSaveUser).toHaveBeenCalled(); // Can't easily spy on exported function without importing * as
        expect(localStorage.getItem('user')).toContain('Updated Bio');
        expect(mockShowMessage).toHaveBeenCalledWith('Profile updated successfully!');
    });

    test('profile form submission handles error', async () => {
        global.fetch.mockResolvedValueOnce({ ok: false });

        const form = document.getElementById('profile-form');
        form.dispatchEvent(new Event('submit'));

        await new Promise(process.nextTick);

        expect(mockShowMessage).toHaveBeenCalledWith('Failed to update profile');
    });
});
