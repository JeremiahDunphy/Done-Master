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
