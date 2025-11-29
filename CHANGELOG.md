# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Mobile Integration Tests**: Added initial structure for mobile integration tests in `mobile/integration_test/`.
- **Web UI**: Added a bottom navigation bar for mobile-friendly navigation.
- **Web UI**: Added "Saved" toggle button to job cards.

### Changed
- **Terminology Refactor**: Replaced "Client" with "Poster" and "Provider" with "Doer" across the entire stack:
    - **Database**: Updated `Role` enum in Prisma schema.
    - **Backend**: Updated API endpoints and logic to handle `POSTER` and `DOER` roles.
    - **Web**: Updated registration, auth logic, and UI components.
    - **Mobile**: Updated models, UI text, and API service mapping.
- **Web UI/UX Improvements**:
    - **Landing Page**: Enhanced typography, added glassmorphism effects, and styled store buttons.
    - **Jobs Dashboard**: Standardized category chips and improved job card layout.
    - **Auth Pages**: Applied glassmorphism styling to Login and Register forms.
    - **Profile Page**: Improved styling and fixed layout issues.
    - **Job Creation**: Polished form layout and validation.

### Fixed
- **Navigation**: Fixed "Done" logo behavior to correctly navigate to Home when logged in.
- **Mobile Build**: Fixed class name mismatches (`MyApp` -> `DoneApp`) and missing imports in `mobile/lib/main.dart`.
- **Web API**: Fixed `Content-Type` header issue for `FormData` uploads in `web/js/shared/api.js`.
- **Web Logic**: Fixed `SyntaxError` and `ReferenceError` in `web/js/features/jobs/jobs.ui.js`.
- **Backend**: Updated `server.js` to handle `NaN` coordinates gracefully.
- **Profile**: Fixed bug where email was displayed repeatedly on the profile page.
- **Profile**: Fixed bug where hourly rate input was hidden for Clients (now Posters).

## [v0.2.0] - E2E Testing & Verification

### Added
- **Backend Tests**: Implemented comprehensive Jest tests for all API endpoints (`backend/tests/api.test.js`).
- **Web E2E Tests**: Implemented Puppeteer-based E2E tests for critical user flows (`web/tests/e2e.test.js`):
    - Landing page load.
    - User registration and login.
    - Job creation with photo upload simulation.
    - User profile display.
- **Mobile Tests**: Created scaffold for Flutter integration tests (`mobile/integration_test/app_test.dart`).

### Fixed
- **Web Socket**: Replaced CDN-based `socket.io` with local library for better offline stability.
- **Backend**: Fixed various minor bugs discovered during testing.

## [v0.1.0] - Initial Release

### Added
- **Backend**:
    - Node.js + Express server setup.
    - Prisma ORM with SQLite database.
    - JWT Authentication (Login/Register).
    - API Endpoints for Jobs, Users, Reviews, and Notifications.
    - File upload support using Multer.
    - Real-time chat support using Socket.io.
- **Web Application**:
    - Vanilla JavaScript SPA architecture.
    - Custom Router for navigation.
    - Features: Landing Page, Login/Register, Job Feed, Job Details, Create Job, Profile, Chat.
- **Mobile Application (Flutter)**:
    - Cross-platform mobile app structure.
    - Features: Authentication, Job Feed, Job Details, Profile, Chat.
    - Google Maps integration for job locations.
    - Stripe payment integration (UI mock).
