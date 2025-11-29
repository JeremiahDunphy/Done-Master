import { initTheme, toggleTheme } from './shared/theme.js';
import { loadUser, state } from './shared/state.js';
import { showPage, renderPage } from './shared/router.js';
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

        if (state.currentUser && state.currentUser.role === 'CLIENT') {
            const btn = document.getElementById('create-job-btn');
            if (btn) btn.style.display = 'block';
        }
    } else {
        if (initialPage === 'home' || initialPage === 'create-job' || initialPage === 'chat' || initialPage === 'profile') {
            showPage('login');
        } else {
            showPage(initialPage);
        }
    }
})();
