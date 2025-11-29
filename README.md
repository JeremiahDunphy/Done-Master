# Done - Gig Marketplace

A modern gig marketplace connecting Clients with Providers for quick jobs.

## Features
- **Job Posting:** Post jobs with photos, zip code location, and daily rates.
- **Interactive Map:** Explore jobs on a map with distance-based filtering.
- **Real-time Chat:** Message between Clients and Providers.
- **Secure Payments:** Stripe integration for secure transactions.
- **Reviews:** 5-star rating system.
- **Mobile App:** Full-featured Flutter app (Android/iOS).

## Tech Stack
- **Frontend:** Vanilla JS, HTML, CSS (Web) / Flutter (Mobile)
- **Backend:** Node.js, Express, Socket.io
- **Database:** SQLite (via Prisma)
- **Services:** Stripe (Payments), Nominatim (Geocoding)

## Setup

### Backend
1.  `cd backend`
2.  `npm install`
3.  `cp .env.example .env` (Add your Stripe Key)
4.  `npx prisma db push`
5.  `npm start`

### Web Frontend
1.  `cd web`
2.  `npm install`
3.  `npx serve -p 8000`
4.  Open `http://localhost:8000`

### Mobile App
1.  `cd mobile`
2.  `flutter pub get`
3.  `flutter run`

## License
MIT
