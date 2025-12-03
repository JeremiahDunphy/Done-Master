import { jest } from '@jest/globals';
import { state } from '../js/shared/state.js';

// Mock dependencies
const mockLoadUser = jest.fn();
const mockShowPage = jest.fn();
const mockInitChat = jest.fn();

jest.unstable_mockModule('../js/shared/state.js', () => ({
    state: { currentUser: null },
    loadUser: mockLoadUser,
    saveUser: jest.fn(),
    clearUser: jest.fn()
}));

jest.unstable_mockModule('../js/shared/router.js', () => ({
    showPage: mockShowPage,
    renderPage: jest.fn(),
    handleLogoClick: jest.fn()
}));

jest.unstable_mockModule('../js/shared/theme.js', () => ({
    initTheme: jest.fn(),
    toggleTheme: jest.fn()
}));

jest.unstable_mockModule('../js/features/auth/auth.ui.js', () => ({
    initAuth: jest.fn()
}));

jest.unstable_mockModule('../js/features/jobs/jobs.ui.js', () => ({
    initJobs: jest.fn(),
    loadJobs: jest.fn()
}));

jest.unstable_mockModule('../js/features/jobs/map.ui.js', () => ({
    initMap: jest.fn()
}));

jest.unstable_mockModule('../js/features/profile/profile.ui.js', () => ({
    initProfile: jest.fn()
}));

jest.unstable_mockModule('../js/features/chat/chat.ui.js', () => ({
    initChat: mockInitChat,
    startChatWith: jest.fn()
}));

jest.unstable_mockModule('../js/features/reviews/reviews.ui.js', () => ({}));
jest.unstable_mockModule('../js/features/payments/payments.ui.js', () => ({}));
jest.unstable_mockModule('../js/features/notifications/notifications.ui.js', () => ({
    initNotifications: jest.fn()
}));

// Import main.js dynamically to trigger execution
// Note: main.js executes immediately on import.
// We need to reset modules between tests if we want to test side effects,
// but Jest ESM support for resetting modules is tricky.
// Instead, we can test the side effects of the single import.

describe('Main App Initialization', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        document.body.innerHTML = `
            <nav id="navbar" class="hidden"></nav>
            <div id="app"></div>
        `;
        // Mock window.location
        delete window.location;
        window.location = { pathname: '/' };
    });

    test('initializes app correctly', async () => {
        mockLoadUser.mockReturnValue(true); // User logged in

        await import('../js/main.js');

        expect(mockLoadUser).toHaveBeenCalled();
        expect(mockInitChat).toHaveBeenCalled();
        // Since we can't easily re-import main.js, this test might be limited to one-time execution check
        // or we rely on the fact that it runs once per test file execution context.
    });
});
