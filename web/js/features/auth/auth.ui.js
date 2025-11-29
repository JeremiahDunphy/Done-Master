import { login, register } from './auth.service.js';
import { showMessage } from '../../shared/utils.js';
import { showPage } from '../../shared/router.js';
import { loadJobs } from '../jobs/jobs.ui.js';

export function initAuth() {
    window.acceptTerms = () => {
        document.getElementById('register-terms').checked = true;
        document.getElementById('terms-modal').style.display = 'none';
        showMessage('Terms accepted', 'success');
    };

    document.getElementById('login-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        console.log('Login form submitted');
        const email = document.getElementById('login-email').value;
        const password = document.getElementById('login-password').value;

        try {
            console.log('Attempting login...');
            await login(email, password);
            console.log('Login successful, redirecting...');
            showPage('home');
            loadJobs();
            showMessage('Login successful!', 'success');
        } catch (error) {
            console.error('Login error:', error);
            showMessage('Login failed. Please check your credentials.');
        }
    });

    document.getElementById('register-form').addEventListener('submit', async (e) => {
        e.preventDefault();
        console.log('Register form submitted');
        window.authSuccess = false;
        window.lastAuthError = null;

        const name = document.getElementById('register-name').value;
        const email = document.getElementById('register-email').value;
        const password = document.getElementById('register-password').value;
        const role = document.getElementById('reg-role').value;
        const terms = document.getElementById('register-terms').checked;

        if (!terms) {
            showMessage('Please accept the Terms and Conditions');
            return;
        }

        try {
            console.log('Calling register API...');
            await register(email, password, name, role);
            console.log('Registration successful');
            window.authSuccess = true;
            showPage('home');
            loadJobs();
            showMessage('Registration successful!', 'success');
        } catch (error) {
            console.error('Registration error:', error);
            window.lastAuthError = error.message || error;
            showMessage('Registration failed: ' + (error.message || 'Unknown error'));
        }
    });
}
