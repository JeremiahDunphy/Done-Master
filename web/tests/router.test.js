import { jest } from '@jest/globals';
import { state } from '../js/shared/state.js';

// Mock dependencies
const mockLoadProfile = jest.fn();
const mockLoadConversations = jest.fn();
const mockInitChat = jest.fn();
// const mockClearUser = jest.fn(); // Using real clearUser

// Removed state mock

jest.unstable_mockModule('../js/features/profile/profile.ui.js', () => ({
    loadProfile: mockLoadProfile
}));

jest.unstable_mockModule('../js/features/chat/chat.ui.js', () => ({
    loadConversations: mockLoadConversations,
    initChat: mockInitChat
}));

const { showPage, renderPage, updateNavbar } = await import('../js/shared/router.js');

describe('Router', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        state.currentUser = null;
        document.body.innerHTML = `
            <div id="navbar" class="hidden">
                <div id="user-info"></div>
            </div>
            <div id="landing-page" class="page"></div>
            <div id="login-page" class="page hidden"></div>
            <div id="register-page" class="page hidden"></div>
            <div id="home-page" class="page hidden"></div>
            <div id="profile-page" class="page hidden"></div>
            <div id="chat-page" class="page hidden"></div>
            <div id="create-job-page" class="page hidden">
                <form id="create-job-form"></form>
                <div id="photo-preview"></div>
            </div>
        `;
        // Mock window.history.pushState
        window.history.pushState = jest.fn();
    });

    test('showPage updates history and renders page', () => {
        showPage('login');
        expect(window.history.pushState).toHaveBeenCalledWith({ page: 'login' }, '', '/login');
        expect(document.getElementById('login-page').classList.contains('hidden')).toBe(false);
        expect(document.getElementById('landing-page').classList.contains('hidden')).toBe(true);
    });

    test('showPage handles landing page path', () => {
        showPage('landing');
        expect(window.history.pushState).toHaveBeenCalledWith({ page: 'landing' }, '', '/');
    });

    test('renderPage resets create job form', () => {
        // Show create-job first to set it up
        showPage('create-job');
        // Then show another page
        showPage('home');

        // Check if reset logic was triggered (we can't easily check form reset state in jsdom without spy, 
        // but we can check if photo-preview is empty if we put something in it)
        // The code:
        // if (pageName !== 'create-job') { ... createJobForm.reset(); photoPreview.innerHTML = ''; }

        // Let's verify logic by coverage mostly, or spy on reset.
        const form = document.getElementById('create-job-form');
        form.reset = jest.fn();

        renderPage('home');
        expect(form.reset).toHaveBeenCalled();
    });

    test('renderPage loads profile when showing profile page', () => {
        renderPage('profile');
        expect(mockLoadProfile).toHaveBeenCalled();
    });

    test('renderPage loads conversations when showing chat page', () => {
        renderPage('chat');
        expect(mockLoadConversations).toHaveBeenCalled();
    });

    test('updateNavbar shows login/signup when not logged in', () => {
        updateNavbar();
        expect(document.getElementById('user-info').innerHTML).toContain('Login');
        expect(document.getElementById('user-info').innerHTML).toContain('Sign Up');
    });

    test('updateNavbar shows user info when logged in', () => {
        state.currentUser = { name: 'Test User', role: 'CLIENT' };
        updateNavbar();
        expect(document.getElementById('user-info').innerHTML).toContain('Test User');
        expect(document.getElementById('user-info').innerHTML).toContain('CLIENT');
        expect(document.getElementById('user-info').innerHTML).toContain('Logout');
        expect(mockInitChat).toHaveBeenCalled();
    });

    test('logout clears user and shows landing', () => {
        window.logout();
        expect(state.currentUser).toBeNull();
        expect(window.history.pushState).toHaveBeenCalledWith({ page: 'landing' }, '', '/');
    });
});
