# Product Backlog — Future Sprints

Everything below is post-MVP. Sprints 1–8 (the core build) are complete. These are ordered by estimated impact and effort, but can be reprioritized based on user feedback and market signals.

---

## Sprint 9: Remaining Integration Adapters

**Goal:** Cover the long-tail of booking systems that small/mid practices actually use.

| Story | Description | Effort |
|-------|-------------|--------|
| Jane App adapter | REST API integration for allied health (PT, chiro, mental health). Popular in Canada. | M |
| SimplePractice adapter | Partner API for mental health practices. OAuth2 flow. | M |
| Acuity Scheduling adapter | Webhook-based (now Squarespace Scheduling). Similar pattern to Calendly. | S |
| NexHealth adapter | Aggregates dental + medical PMS systems. One integration unlocks many. | M |
| Generic CSV import | Upload a CSV of appointments. Map columns to fields. Fallback for anyone. | S |
| iCal feed adapter | Subscribe to an .ics URL, poll for changes. Covers Outlook, Apple Calendar. | S |

---

## Sprint 10: Staff Management & 2FA

**Goal:** Make the admin experience production-grade. Staff can be invited, managed, and secured with 2FA.

| Story | Description | Effort |
|-------|-------------|--------|
| Staff invitation flow | Owner/admin can invite staff by email. Devise invitable or custom. | M |
| Staff management UI | List, edit roles, deactivate staff. Settings page. | M |
| TOTP 2FA via devise-two-factor | Setup flow with QR code, recovery codes, enforcement per role. | L |
| Password requirements | Minimum length, complexity policy configurable per tenant. | S |
| Session management | View active sessions, revoke remotely. | M |
| Login audit log | Track sign-in attempts (success/failure) with IP and user agent. | S |

---

## Sprint 11: Analytics & Reporting

**Goal:** Give practice owners visibility into wait times, no-show rates, and operational patterns.

| Story | Description | Effort |
|-------|-------------|--------|
| Wait time analytics | Average wait by provider, day of week, time of day. Chart view. | L |
| No-show rate tracking | % no-shows by provider, patient, time slot. Trend over time. | M |
| Check-in time distribution | How long patients wait from check-in to in-room. Histogram. | M |
| Gift card spend report | Total issued, redeemed, outstanding balance. Per-month breakdown. | S |
| Provider utilization | Appointments per provider per day. Capacity planning view. | M |
| CSV export | Download filtered appointment data as CSV. Owner/admin only (HIPAA role check). | S |
| Dashboard widgets | Summary cards on Today View: checked in count, avg wait, running late count. | M |

---

## Sprint 12: Patient Experience Improvements

**Goal:** Make the patient-facing experience richer without compromising PHI safety.

| Story | Description | Effort |
|-------|-------------|--------|
| Multi-language SMS | Spanish, French, Mandarin templates. Language preference per patient. | L |
| SMS opt-in/opt-out | Patient can reply STOP to opt out. Track consent status. | M |
| Appointment reminders | Scheduled SMS 24h and 2h before appointment. Configurable per tenant. | M |
| Apple/Google Wallet pass | Generate .pkpass or Google Wallet link from patient status page. | L |
| Patient feedback | Post-visit SMS survey (1-5 rating). Aggregate NPS score per provider. | M |
| Status page improvements | Show estimated wait time countdown. Position in queue ("3 patients ahead"). | M |

---

## Sprint 13: Advanced Scheduling

**Goal:** Move from ingestion-only to Schedulite being a scheduling source of truth for smaller practices.

| Story | Description | Effort |
|-------|-------------|--------|
| Provider schedule templates | Define weekly availability blocks per provider. | L |
| Online booking page | Public booking page per practice. Patient selects provider + time slot. | XL |
| Recurring appointments | Weekly/biweekly/monthly recurrence. Auto-generate future appointments. | L |
| Waitlist management | Patients can join a waitlist. Auto-notify when slot opens. | L |
| Buffer time between appointments | Configurable gap between appointments per provider. | S |
| Cancellation + rescheduling | Patient can cancel/reschedule via SMS reply or status page link. | M |

---

## Sprint 14: Notifications & Communication

**Goal:** Expand beyond SMS to support the channels practices and patients actually use.

| Story | Description | Effort |
|-------|-------------|--------|
| Email notifications | Configurable email templates alongside SMS. Appointment confirmations, delays. | M |
| Staff push notifications | Browser push notifications for new check-ins and status changes. | M |
| Slack/Teams integration | Post check-ins and delay alerts to a practice's Slack/Teams channel. | M |
| SMS conversation view | Staff-facing view of full SMS thread with each patient. Reply inline. | L |
| Notification preferences | Per-tenant config: which events trigger SMS, email, push. | M |

---

## Sprint 15: Tenant Onboarding & Billing

**Goal:** Self-service onboarding so practices can sign up, configure, and start using Schedulite without manual setup.

| Story | Description | Effort |
|-------|-------------|--------|
| Self-service signup | Practice signs up, creates tenant, adds first admin. | L |
| Onboarding wizard | Step-by-step: practice info, Twilio setup, first provider, first integration. | L |
| Stripe billing integration | Free trial, monthly subscription. Usage-based pricing for SMS. | XL |
| Plan tiers | Free (5 appointments/day), Pro (unlimited, integrations), Enterprise (API, SSO). | L |
| Usage dashboard | SMS count, appointment count, gift card spend. Current plan usage vs limits. | M |
| Tenant branding | Custom logo, accent color override per practice. Shows on patient status page. | M |

---

## Sprint 16: Infrastructure & Reliability

**Goal:** Production hardening for scale and compliance certification.

| Story | Description | Effort |
|-------|-------------|--------|
| System specs (Capybara) | End-to-end browser tests for 3 core screens. CI integration. | L |
| Lighthouse CI | Automated Lighthouse scoring in CI. Target >= 95 mobile. | M |
| Sentry integration | Wire up DSN, configure PHI scrubbing in error reports. | S |
| Sidekiq monitoring | Mount Sidekiq Web UI at /sidekiq, admin-only auth. | S |
| Rate limiting | Rack::Attack for API endpoints, sign-in, webhooks. | M |
| Database connection pooling | PgBouncer setup, connection pool tuning for production. | M |
| CI/CD pipeline | GitHub Actions: RSpec, RuboCop, Brakeman, bundler-audit, deploy. | L |
| Uptime monitoring | Health check endpoint monitoring, PagerDuty/Opsgenie integration. | S |
| SOC 2 prep | Audit logging export, access review tooling, policy documentation. | XL |

---

## Sprint 17: Mobile & Platform

**Goal:** Native-quality mobile experience for staff who are always on their feet.

| Story | Description | Effort |
|-------|-------------|--------|
| PWA configuration | Service worker, offline support, installable on mobile home screen. | M |
| Native-feel gestures | Swipe-to-check-in on appointment rows. Pull-to-refresh on dashboard. | L |
| Haptic feedback | Vibrate on successful check-in (mobile browsers that support it). | S |
| Tablet layout | Two-column layout on iPad: timeline left, detail panel right. | M |
| React Native wrapper | Optional native shell for App Store distribution. Push notifications. | XL |

---

## Effort Key

| Size | Meaning |
|------|---------|
| S | A few hours. Single file or component change. |
| M | 1–2 days. New service, controller, or UI section. |
| L | 3–5 days. New feature area with multiple moving parts. |
| XL | 1–2 weeks. Major feature with external integrations. |

---

## Prioritization Notes

**Highest impact, lowest effort (do first):**
- Sprint 9 (remaining adapters) — extends market reach with proven pattern
- Sprint 10 (staff management + 2FA) — required for any real deployment
- Sprint 16 items: Sentry, Sidekiq UI, CI/CD, rate limiting — operational necessities

**Highest impact, highest effort (plan carefully):**
- Sprint 11 (analytics) — key differentiator, practices need data
- Sprint 15 (self-service onboarding + billing) — unlocks growth
- Sprint 13 (scheduling) — transforms from add-on to platform

**Nice-to-have (defer until demand proves it):**
- Sprint 17 (native mobile) — PWA may be sufficient
- Sprint 14 (multi-channel notifications) — SMS is the core value prop
- Sprint 12 multi-language — important but can wait for first non-English market entry
