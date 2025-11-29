import { initTheme, toggleTheme } from './shared/theme.js';
import { loadUser, state } from './shared/state.js';
import { showPage, renderPage, handleLogoClick } from './shared/router.js';
window.showPage = showPage;
window.appHandleLogoClick = handleLogoClick;
import { initAuth } from './features/auth/auth.ui.js';
import { initJobs, loadJobs } from './features/jobs/jobs.ui.js';
import { initMap } from './features/jobs/map.ui.js';
import { initChat } from './features/chat/chat.ui.js';
import { initProfile } from './features/profile/profile.ui.js';
import './features/reviews/reviews.ui.js'; // Import to register window globals
import './features/payments/payments.ui.js'; // Import to register window globals

// Initialize Theme
initTheme();
window.toggleTheme = toggleTheme;

// Handle browser back/forward buttons
window.addEventListener('popstate', (event) => {
    if (event.state && event.state.page) {
        renderPage(event.state.page);
    } else {
        renderPage('landing');
    }
});

// Initialize App State
(function init() {
    const path = window.location.pathname;
    let initialPage = 'landing';

    if (path === '/login') initialPage = 'login';
    else if (path === '/register') initialPage = 'register';
    else if (path === '/home') initialPage = 'home';
    else if (path === '/create-job') initialPage = 'create-job';
    else if (path === '/chat') initialPage = 'chat';
    else if (path === '/profile') initialPage = 'profile';

    // Initialize Features
    initAuth();
    initJobs();
    initChat();
    initProfile();

    if (loadUser()) {
        // Init Notifications if logged in
        import('./features/notifications/notifications.ui.js').then(({ initNotifications }) => {
            initNotifications();
        });

        if (initialPage === 'landing' || initialPage === 'login' || initialPage === 'register') {
            showPage('home');
        } else {
            showPage(initialPage);
        }
        loadJobs();

        document.getElementById('bottom-nav').style.display = 'flex';
        document.getElementById('navbar').style.display = 'none'; // Hide top navbar on mobile/app view if preferred, or keep both. 
        // For this design, let's keep top navbar for Logo/Theme but maybe hide auth buttons?
        // Actually, let's just show bottom nav.

        if (state.currentUser && state.currentUser.role === 'POSTER') {
            const btn = document.getElementById('create-job-btn');
            if (btn) btn.style.display = 'block';
            const navBtn = document.getElementById('nav-create-job');
            if (navBtn) navBtn.style.display = 'flex';
        } else {
            const navBtn = document.getElementById('nav-create-job');
            if (navBtn) navBtn.style.display = 'none';
        }
    } else {
        if (initialPage === 'home' || initialPage === 'create-job' || initialPage === 'chat' || initialPage === 'profile') {
            showPage('login');
        } else {
            showPage(initialPage);
        }
    }
})();
