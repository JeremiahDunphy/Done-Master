import { state, clearUser } from './state.js';
import { loadProfile } from '../features/profile/profile.ui.js';
import { loadConversations, initChat } from '../features/chat/chat.ui.js';

export function showPage(pageName) {
    const path = pageName === 'landing' ? '/' : `/${pageName}`;
    window.history.pushState({ page: pageName }, '', path);
    renderPage(pageName);
}

export function renderPage(pageName) {
    document.querySelectorAll('.page').forEach(page => {
        page.classList.add('hidden');
    });

    const targetPage = document.getElementById(`${pageName}-page`);
    if (targetPage) {
        targetPage.classList.remove('hidden');
    }

    if (pageName !== 'create-job') {
        const createJobForm = document.getElementById('create-job-form');
        if (createJobForm) {
            createJobForm.reset();
            const photoPreview = document.getElementById('photo-preview');
            if (photoPreview) photoPreview.innerHTML = '';
        }
    }

    const navbar = document.getElementById('navbar');
    if (pageName === 'login' || pageName === 'register' || pageName === 'landing') {
        navbar.classList.remove('hidden');
        updateNavbar();
    } else {
        navbar.classList.remove('hidden');
        updateNavbar();
    }

    if (pageName === 'profile') {
        loadProfile();
    }

    if (pageName === 'chat') {
        loadConversations();
    }
}

export function updateNavbar() {
    const userInfo = document.getElementById('user-info');
    const themeBtn = `<button id="theme-toggle" class="btn btn-secondary" onclick="window.toggleTheme()" style="padding: 0.5rem; border-radius: 50%; width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; margin-right: 1rem;">${document.documentElement.getAttribute('data-theme') === 'light' ? '🌙' : '☀️'}</button>`;

    if (state.currentUser) {
        userInfo.innerHTML = `
      ${themeBtn}
      <span class="badge" style="margin-right: 0.5rem;">${state.currentUser.role}</span>
      <button class="btn btn-outline" onclick="showPage('chat')" style="margin-right: 0.5rem;">💬 Messages</button>
      <span style="margin-right: 1rem; cursor: pointer;" onclick="showPage('profile')">${state.currentUser.name || state.currentUser.email}</span>
      <button class="btn btn-secondary" onclick="window.logout()">Logout</button>
    `;
        initChat();
    } else {
        userInfo.innerHTML = `
            ${themeBtn}
            <div id="auth-buttons">
                <button onclick="showPage('login')" class="btn btn-outline" style="margin-right: 0.5rem;">Login</button>
                <button onclick="showPage('register')" class="btn btn-primary">Sign Up</button>
            </div>
        `;
    }
}

// Global exposure for onclick handlers
window.showPage = showPage;
window.logout = () => {
    clearUser();
    showPage('landing');
};
