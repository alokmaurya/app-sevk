# Sevk — Home Services Booking App

A clean, mobile-friendly home services booking web app for **Sevk**, a 24×7 business. Customers can sign up, pick a service, choose a date and time, fill in their details, and receive an instant booking reference — all in one seamless flow.

Live at: **https://alokmaurya.github.io/app-sevk/**

---

## Features

### Guest Experience
- Full landing page with hero section, services showcase, how-it-works steps, and CTA
- Sign Up / Log In modal with tabbed forms and inline validation
- Email confirmation support (Supabase Auth)

### Booking Flow (logged-in users)
- 4-step booking flow: **Service → Date & Time → Details → Confirmation**
- Interactive calendar with month navigation and past-date blocking
- Full 24×7 time slot coverage — Morning / Afternoon / Evening & Night
- Customer details form pre-filled from account (name & email)
- Auto-generated booking reference (e.g. `SVK-AB12CD`)

### My Bookings Page
- Stats row: Total · Scheduled · In Progress · Completed
- Filter tabs to view bookings by status
- Rich booking cards with service, status badge, date/time, contact, address, notes
- Status badges: 🔵 Scheduled · 🟡 In Progress · 🟢 Completed

### General
- Red, Black & White brand theme
- Fully responsive — works on mobile and desktop
- Pure HTML, CSS & JavaScript — no build step required
- Supabase backend for auth and data storage

---

## Services Offered

| Service | Description |
|---|---|
| ⚡ Electrician | Wiring, panels & repairs |
| 🔧 Plumber | Leaks, pipes & installations |
| 🧱 Wall Specialists | Plastering, drywall & finishes |
| 🪟 Glass Works | Windows, doors & glazing |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML, CSS, Vanilla JavaScript |
| Auth | Supabase Auth (email + password) |
| Database | Supabase (PostgreSQL) |
| Hosting | GitHub Pages |

---

## File Structure

```
app-sevk/
├── index.html           # Full app — markup, logic, routing
├── style.css            # All styles (CSS variables, responsive)
├── supabase-setup.sql   # Database schema + RLS policies
└── README.md            # Project documentation
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/alokmaurya/app-sevk.git
cd app-sevk
```

### 2. Set up Supabase

1. Create a free project at [supabase.com](https://supabase.com)
2. Go to **Authentication → Providers → Email** and disable **Confirm email** (for local testing)
3. Open **SQL Editor**, paste the contents of `supabase-setup.sql`, and click **Run**
4. Go to **Settings → API** and copy your **Project URL** and **anon key**

### 3. Add your Supabase credentials

Open `index.html` and replace the two placeholder values near the bottom of the `<script>` tag:

```js
const SUPABASE_URL      = 'https://YOUR_PROJECT_ID.supabase.co';
const SUPABASE_ANON_KEY = 'YOUR_ANON_KEY_HERE';
```

### 4. Open locally

```bash
python3 -m http.server 8080
```

Then visit `http://localhost:8080` in your browser.

### 5. Deploy with GitHub Pages

Go to **Settings → Pages → Deploy from branch** (`main`, `/ root`).
Your app will be live at:

```
https://alokmaurya.github.io/app-sevk/
```

---

## Database Schema

The `supabase-setup.sql` file creates a `bookings` table with Row Level Security — users can only read and write their own bookings.

| Column | Type | Description |
|---|---|---|
| `id` | uuid | Primary key |
| `user_id` | uuid | References `auth.users` |
| `ref_number` | text | e.g. `SVK-AB12CD` |
| `service_id` | text | e.g. `electrician` |
| `service_name` | text | e.g. `Electrician` |
| `service_emoji` | text | e.g. `⚡` |
| `date` | date | Appointment date |
| `time` | text | e.g. `10:00 AM` |
| `name` | text | Customer name |
| `phone` | text | Customer phone |
| `email` | text | Customer email |
| `address` | text | Job address |
| `notes` | text | Optional notes |
| `status` | text | `Scheduled` · `In Progress` · `Completed` |
| `created_at` | timestamptz | Auto-set on insert |

> **Note:** The `anon` key is safe to include in frontend code. RLS policies ensure each user can only access their own data. Never use the `service_role` key in the frontend.

---

## Customisation

| What | Where |
|---|---|
| Services list | `SERVICES` array in `index.html` |
| Time slots | `TIME_GROUPS` array in `index.html` |
| Brand colours | CSS variables in `style.css` (`:root`) |
| Logo | Replace `.logo-placeholder` in `index.html` with an `<img>` tag |
| Business name | Update `Sevk` references in `index.html` header |
| Booking statuses | `STATUS_META` object in `index.html` |

---

## Roadmap

- [ ] Add logo once finalised
- [ ] Admin dashboard to view and update booking statuses
- [ ] SMS / email confirmation on booking (e.g. Twilio, Resend)
- [ ] Password reset flow
- [ ] Google / Apple sign-in via Supabase OAuth

---

## License

MIT — free to use and modify.
