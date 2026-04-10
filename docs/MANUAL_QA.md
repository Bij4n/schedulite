# Manual QA Checklist

The automated test suite (`bundle exec rspec`) covers every page render, role
permission, and request/response path. **This document covers the things specs
can't catch** — JS interactions, animations, third-party redirects, real
device behavior, and end-to-end flows that rely on a browser.

Run this checklist on a real desktop browser AND a real iPhone (or Android)
before any release.

---

## Setup

- Sign in as a fresh **owner** account on the live site or staging.
- Open Chrome DevTools → Console. **Any red error in the console is a fail.**
- Have a second device ready for the patient-facing flows.

---

## 1. Auth & onboarding

- [ ] `/users/sign_in` loads on mobile, no console errors
- [ ] Sign in with valid credentials → lands on `/dashboard` (or `/onboarding` if new)
- [ ] Sign in with **wrong password** → see inline error, stay on form
- [ ] `/register` → fill all fields → submit → land on `/onboarding` step 1
- [ ] Onboarding: walk through all 4 steps, click **Skip** on each, end up on dashboard
- [ ] Onboarding: walk through all 4 steps, fill in real data, end up on dashboard
- [ ] `/users/password/new` → enter email → confirmation message
- [ ] Click the password-reset email link → `/users/password/edit` loads, set new password works

## 2. Dashboard & live updates

- [ ] `/dashboard` shows today's appointments grouped AM / Lunch / PM
- [ ] Provider filter dropdown narrows the list
- [ ] Week view toggle works
- [ ] Date strip arrows navigate forward/back without losing the provider filter
- [ ] **Tap "Check In"** on an appointment → row updates **without a full page reload** (Turbo Stream)
- [ ] Open `/dashboard` in two tabs side-by-side. Check in a patient in tab 1 → tab 2 updates within 1 second.
- [ ] Empty state appears when no appointments today

## 3. Patient & appointment CRUD

- [ ] `/patients/new` → create a patient with name + phone → redirects to patient detail
- [ ] Patient detail page shows phone formatted as `(555) 123-4567`
- [ ] Edit patient → save → see updated values
- [ ] Search bar in the nav: type 2+ characters → dropdown shows results
- [ ] Click a search result → navigates to that patient/appointment
- [ ] **XSS check:** create a patient with name `<img src=x onerror=alert(1)>`. Search for "img". Confirm NO alert fires (the search dropdown should display it as plain text).
- [ ] Create appointment → pick provider + patient + time → redirects to appointment detail
- [ ] Appointment status transitions: scheduled → checked_in → in_room → complete (each via the action button)
- [ ] Cancel appointment → status updates, row turns gray
- [ ] No-show appointment → status updates, no-show fee charge attempted (Stripe test mode)

## 4. Delay workflow

- [ ] From a provider page, click "Mark as running late"
- [ ] Pick a template, enter delay minutes, optionally enable gift card
- [ ] Submit → see workflow detail with affected appointments listed
- [ ] Verify SmsService.call was triggered (check Sidekiq dashboard or logs)
- [ ] In test mode, reply "1" / "2" / "3" via the Twilio webhook simulator → response status updates

## 5. Stripe billing

- [ ] `/settings/billing` shows current plan (Free) with limits
- [ ] Click "Upgrade to Pro" → redirects to Stripe Checkout (test mode)
- [ ] Use test card `4242 4242 4242 4242` → checkout succeeds → webhook fires → plan updates to "Pro"
- [ ] After upgrade, "Manage Billing" button appears → opens Stripe Billing Portal
- [ ] **As a staff user:** visit `/settings/billing` → should redirect to root with "Not authorized" alert
- [ ] **As a provider user:** same — redirected with alert

## 6. Patient portal

- [ ] On the marketing site, find the portal sign-in link (or visit `/portal/login`)
- [ ] Enter your patient phone number → submit
- [ ] Receive SMS with magic link → tap link
- [ ] Land on `/portal/appointments` → see upcoming + past appointments
- [ ] Tap "Update profile" → edit address, city, state, zip → save
- [ ] Sign out → session ends → revisit `/portal/appointments` → redirected to login
- [ ] **Magic link expiry:** request a link, wait 16 minutes, try the link → "Invalid or expired link"

## 7. Kiosk

- [ ] On a tablet, open `/kiosk/<your-subdomain>`
- [ ] Enter a patient's phone number → check-in confirmation page
- [ ] Patient is now marked "checked_in" on the dashboard
- [ ] Try a phone number that doesn't exist → friendly error message

## 8. Settings navigation

- [ ] `/settings/profile` — edit your own first/last name + email
- [ ] `/settings/practice` — edit practice address (owner only); confirm geocoding triggers
- [ ] `/settings/staff` — invite a new staff member; verify role dropdown
- [ ] `/settings/staff/:id/shifts` — add a recurring shift
- [ ] `/settings/integrations` — see all available adapters; add a fake one
- [ ] `/settings/sync_health` — see integration status
- [ ] `/settings/analytics` — charts render
- [ ] `/settings/timesheet` — week view shows clock-in/out
- [ ] `/settings/time_off` — pending requests visible
- [ ] `/settings/workflow_templates` — create a delay template
- [ ] `/settings/billing` — see plan + upgrade options
- [ ] **As a manager:** all of the above except `/settings/practice` (owner-only)
- [ ] **As a staff:** only `/settings/profile` accessible

## 9. Multi-location

- [ ] `/locations` → empty state on a fresh tenant
- [ ] Add a location with address → row appears, address is geocoded after a few seconds
- [ ] Edit the location → changes save
- [ ] Remove the location → confirmation prompt → row disappears
- [ ] **On mobile:** location row stacks Edit/Remove below the title (not overflowing)

## 10. Marketing & integrations directory

- [ ] `/` (landing page) loads with no console errors
- [ ] **Feature cards animate in** with stagger as you scroll past them
- [ ] **Number badges pop** with a spring curve and turn teal on hover
- [ ] Hover lift effect works on desktop, disabled on mobile
- [ ] CTAs are full-width on mobile with 52px+ tap targets
- [ ] `/integrations` lists all supported systems
- [ ] **Floating "Don't see your system?" CTA** appears after scrolling ~400px
- [ ] CTA hides when the static section at the bottom enters view
- [ ] Tap × to dismiss → stays hidden for the rest of the session
- [ ] Reload the page → CTA stays hidden (sessionStorage works)
- [ ] **Private browsing mode:** dismiss button still works (sessionStorage gracefully no-ops)

## 11. PWA

- [ ] On Chrome mobile, visit `/dashboard` → install prompt appears (or via menu)
- [ ] Install → app icon appears on home screen → opens in standalone mode
- [ ] Go offline → cached pages still load (404 fallback for new pages)
- [ ] Service worker registered (DevTools → Application → Service Workers)

## 12. Email

- [ ] Create an appointment for a patient with an email address → confirmation email arrives with .ics attachment
- [ ] Add appointment to Apple Calendar / Google Calendar via the .ics → all-day check
- [ ] Trigger a delay → delay-notification email arrives
- [ ] As an owner, wait for the 7am cron → daily digest email arrives with today's schedule

## 13. Accessibility & responsiveness spot-checks

- [ ] Tab through the dashboard with keyboard only → focus visible on every interactive element
- [ ] Screen reader (VoiceOver / TalkBack) reads form labels correctly
- [ ] Lighthouse mobile score ≥ 90 on `/` and `/dashboard`
- [ ] No horizontal scroll on iPhone SE width (375px)
- [ ] Dark mode: toggle system → app re-renders without breaking

---

## Reporting bugs

- Tag each finding with which step number it came from.
- Include: device, browser, exact URL, console error if any, screenshot.
- File in `docs/PRODUCT_BACKLOG.md` under "Bugs found in QA pass YYYY-MM-DD".
