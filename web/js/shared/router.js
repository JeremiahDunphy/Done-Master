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

    // Show the requested page
    const pageToShow = document.getElementById(`${pageName}-page`);
    if (pageToShow) {
        pageToShow.classList.remove('hidden');
    }

    if (pageName !== 'create-job') {
        const createJobForm = document.getElementById('create-job-form');
        if (createJobForm) {
            createJobForm.reset();
            const photoPreview = document.getElementById('photo-preview');
            if (photoPreview) photoPreview.innerHTML = '';
        }
    }

    // Bottom Navigation Logic
    const bottomNav = document.getElementById('bottom-nav');
    if (bottomNav) {
        if (['home', 'create-job', 'chat', 'profile'].includes(pageName)) {
            bottomNav.style.display = 'flex';
            // Update active state
            document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
            const activeLink = document.querySelector(`.nav-item[onclick="showPage('${pageName}')"]`);
            if (activeLink) activeLink.classList.add('active');
        } else {
            bottomNav.style.display = 'none';
        }
    }

    // Top Navbar Logic
    const navbar = document.getElementById('navbar');
    if (pageName === 'landing' || pageName === 'login' || pageName === 'register') {
        navbar.style.display = 'block'; // Ensure visible on auth pages
        navbar.classList.remove('hidden');
        updateNavbar();
    } else {
        // On app pages, we can hide the top navbar or keep it simple
        // For now, let's keep it but maybe simplify it in updateNavbar
        navbar.style.display = 'block';
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
        // If logged in and on app pages, top nav can just be Logo + Theme
        // The bottom nav handles navigation.
        // We can hide the user info block in top nav to clean it up, or keep just the theme toggle.
        userInfo.innerHTML = `
            ${themeBtn}
            <span class="badge" style="margin-right: 0.5rem;">${state.currentUser.role}</span>
            <!-- Logout button is useful to keep accessible -->
            <button class="btn btn-secondary" onclick="window.logout()" style="padding: 0.5rem 1rem; font-size: 0.8rem;">Logout</button>
        `;

        // Handle Create Job button visibility in Bottom Nav
        const navBtn = document.getElementById('nav-create-job');
        if (navBtn) {
            navBtn.style.display = state.currentUser.role === 'POSTER' ? 'flex' : 'none';
        }

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

export function handleLogoClick() {
    if (state.currentUser) {
        showPage('home');
    } else {
        showPage('landing');
    }
}

window.handleLogoClick = handleLogoClick;
