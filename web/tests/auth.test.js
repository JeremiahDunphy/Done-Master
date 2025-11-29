import { jest } from '@jest/globals';

// Mock dependencies
const mockLogin = jest.fn();
const mockRegister = jest.fn();
const mockShowMessage = jest.fn();
const mockShowPage = jest.fn();
const mockLoadJobs = jest.fn();

jest.unstable_mockModule('../js/features/auth/auth.service.js', () => ({
    login: mockLogin,
    register: mockRegister
}));

jest.unstable_mockModule('../js/shared/utils.js', () => ({
    showMessage: mockShowMessage
}));

jest.unstable_mockModule('../js/shared/router.js', () => ({
    showPage: mockShowPage
}));

jest.unstable_mockModule('../js/features/jobs/jobs.ui.js', () => ({
    loadJobs: mockLoadJobs
}));

const { initAuth } = await import('../js/features/auth/auth.ui.js');

describe('Auth UI', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        document.body.innerHTML = `
            <div id="terms-modal" style="display: block;"></div>
            <input type="checkbox" id="register-terms" />
            
            <form id="login-form">
                <input id="login-email" value="test@example.com" />
                <input id="login-password" value="password" />
                <button type="submit">Login</button>
            </form>

            <form id="register-form">
                <input id="register-name" value="Test User" />
                <input id="register-email" value="new@example.com" />
                <input id="register-password" value="password" />
                <select id="reg-role"><option value="POSTER">Client</option></select>
                <button type="submit">Register</button>
            </form>
        `;
        initAuth();
    });

    test('acceptTerms should check the box and hide modal', () => {
        window.acceptTerms();
        expect(document.getElementById('register-terms').checked).toBe(true);
        expect(document.getElementById('terms-modal').style.display).toBe('none');
        expect(mockShowMessage).toHaveBeenCalledWith('Terms accepted', 'success');
    });

    test('login form submission success', async () => {
        mockLogin.mockResolvedValue({ id: 1, name: 'User' });

        const form = document.getElementById('login-form');
        form.dispatchEvent(new Event('submit'));

        // Wait for async handlers
        await new Promise(process.nextTick);

        expect(mockLogin).toHaveBeenCalledWith('test@example.com', 'password');
        expect(mockShowPage).toHaveBeenCalledWith('home');
        expect(mockLoadJobs).toHaveBeenCalled();
        expect(mockShowMessage).toHaveBeenCalledWith('Login successful!', 'success');
    });

    test('login form submission failure', async () => {
        mockLogin.mockRejectedValue(new Error('Auth failed'));

        const form = document.getElementById('login-form');
        form.dispatchEvent(new Event('submit'));

        await new Promise(process.nextTick);

        expect(mockLogin).toHaveBeenCalled();
        expect(mockShowMessage).toHaveBeenCalledWith(expect.stringContaining('Login failed'));
    });

    test('register form submission success', async () => {
        document.getElementById('register-terms').checked = true;
        mockRegister.mockResolvedValue({ id: 2, name: 'New User' });

        const form = document.getElementById('register-form');
        form.dispatchEvent(new Event('submit'));

        await new Promise(process.nextTick);

        expect(mockRegister).toHaveBeenCalledWith('new@example.com', 'password', 'Test User', 'POSTER');
        expect(mockShowPage).toHaveBeenCalledWith('home');
        expect(mockLoadJobs).toHaveBeenCalled();
        expect(mockShowMessage).toHaveBeenCalledWith('Registration successful!', 'success');
    });

    test('register form submission fails if terms not accepted', async () => {
        document.getElementById('register-terms').checked = false;

        const form = document.getElementById('register-form');
        form.dispatchEvent(new Event('submit'));

        await new Promise(process.nextTick);

        expect(mockRegister).not.toHaveBeenCalled();
        expect(mockShowMessage).toHaveBeenCalledWith(expect.stringContaining('accept the Terms'));
    });

    test('register form submission failure', async () => {
        document.getElementById('register-terms').checked = true;
        mockRegister.mockRejectedValue(new Error('Email exists'));

        const form = document.getElementById('register-form');
        form.dispatchEvent(new Event('submit'));

        await new Promise(process.nextTick);

        expect(mockRegister).toHaveBeenCalled();
        expect(mockShowMessage).toHaveBeenCalledWith(expect.stringContaining('Registration failed'));
    });
});
