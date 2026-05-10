# Sevk — Home Services Booking Tool

A clean, mobile-friendly online booking tool for **Sevk**, a 24×7 home services business. Customers can select a service, pick a date and time, fill in their details, and receive a booking reference — all in one seamless flow.

---

## Services Offered

| Service | Description |
|---|---|
| ⚡ Electrician | Wiring, panels & repairs |
| 🔧 Plumber | Leaks, pipes & installations |
| 🧱 Wall Specialists | Plastering, drywall & finishes |
| 🪟 Glass Works | Windows, doors & glazing |

---

## Features

- 4-step booking flow: Service → Date & Time → Details → Confirmation
- Interactive calendar with month navigation
- Full 24×7 time slot coverage (Morning / Afternoon / Evening & Night)
- Customer details form with name, phone, email, address & notes
- Auto-generated booking reference number (e.g. `SVK-AB12CD`)
- Red, Black & White brand theme
- Fully responsive — works on mobile and desktop
- Pure HTML, CSS & JavaScript — no dependencies or frameworks

---

## File Structure

```
app-sevk/
├── index.html       # Main booking app (markup + JavaScript logic)
├── style.css        # All styles (extracted from index.html)
└── README.md        # Project documentation
```

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/alokmaurya/app-sevk.git
cd app-sevk
```

### 2. Open locally
Just open `index.html` in any browser — no build step or server required.

### 3. Deploy with GitHub Pages
Go to **Settings → Pages → Deploy from branch** (`main`, `/ root`) and your booking tool will be live at:

```
https://alokmaurya.github.io/app-sevk/
```

---

## Customisation

| What | Where |
|---|---|
| Services list | `SERVICES` array in `index.html` |
| Time slots | `TIME_GROUPS` array in `index.html` |
| Brand colors | CSS variables in `style.css` (`:root`) |
| Logo | Replace `.logo-placeholder` in `index.html` with an `<img>` tag |
| Business name | Update `Sevk` references in `index.html` header |

---

## Roadmap

- [ ] Add logo once finalised
- [ ] Connect backend / form submission (e.g. EmailJS, Formspree, or custom API)
- [ ] Admin dashboard to view & manage bookings
- [ ] SMS / email confirmation on booking

---

## License

MIT — free to use and modify.
