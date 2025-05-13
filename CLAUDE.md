# Schedulite — CLAUDE.md

> Persistent context for Claude Code. Read this before every work session.

## 1. What we're building

Schedulite is a real-time appointment check-in and wait-time communication platform for medical practices. Patients book through whatever system the practice already uses (Epic, Athena, Jane, Calendly, etc.). Schedulite ingests those appointments, lets the front-desk check patients in, and pushes live SMS updates as wait times change ("Dr. Lee is running ~20 min behind — feel free to grab a coffee, we'll text you 10 min before you're up").

If a patient is delayed past a configurable threshold, the practice can automatically issue a **Square gift card** to a nearby small business as a goodwill gesture.

**The core insight:** people don't mind waiting. They mind not being told. Schedulite turns waiting rooms from hostage situations into respectful communication.

## 2. MVP scope

In scope for v1:

- Multi-tenant Rails app (one practice = one tenant, row-level scoping via `acts_as_tenant`)
- Staff auth via Devise (email + password, 2FA optional)
- Patient identification via phone number — no patient accounts, magic-link consent flow on first SMS
- Appointment ingestion from integrations (see §4)
- Staff dashboard: today's schedule, check-in button, "running late" controls, per-appointment status
- Real-time updates to staff dashboard via Turbo Streams over ActionCable
- SMS notifications via Twilio (check-in confirmation, delay notice, "you're next" alert)
- Square gift card issuance when delay exceeds threshold
- Audit log for all PHI access
- Public REST API + webhooks for partner integrations
- Patient-facing status page (no login, accessed via signed URL in SMS)

Out of scope for v1: insurance, billing, telehealth, intake forms, provider scheduling, multi-language SMS (English only for now), native mobile apps.

## 3. Tech stack

- Ruby 3.3, Rails 7.2
- PostgreSQL 16 (with `pgcrypto` for column-level encryption of PHI fields)
- Redis 7 (ActionCable + Sidekiq)
- Sidekiq for background jobs
- Hotwire (Turbo + Stimulus) for the frontend
- Tailwind CSS 3 + a small custom component library
- ViewComponent for reusable UI pieces
- RSpec + FactoryBot + VCR for tests
- Devise + devise-two-factor for staff auth
- acts_as_tenant for multi-tenancy
- Lockbox + blind_index for encrypted PHI fields (patient name, DOB, phone)
- audited gem for audit logging
- Twilio Ruby SDK
- Square Ruby SDK
- fhir_client for FHIR R4 integrations
- Sentry for error tracking, Lograge for structured logs

## 4. Integrations (the moat)

**Strategy:** the EHR integration market is fragmented but most modern systems now expose **FHIR R4** thanks to ONC/CMS rules. Build one solid FHIR adapter and we cover Epic, Cerner/Oracle Health, Athenahealth, eClinicalWorks, NextGen, Allscripts/Veradigm, Meditech, and DrChrono. Then add bespoke adapters for the SMB systems that don't speak FHIR well.

All integrations live under `app/services/integrations/` and implement this interface:

```ruby
module Integrations
  class Adapter
    def fetch_appointments(date_range:); end          # returns [AppointmentDTO]
    def push_status(appointment_id:, status:); end    # optional write-back
    def supports_webhooks?; end
    def verify_webhook(request); end
    def parse_webhook(payload); end                   # returns AppointmentDTO
  end
end
```

Adapters to ship in v1 (pick the order based on what's quickest to wire up):

1. **FHIR R4 generic adapter** — covers Epic, Athena, Cerner, eCW, NextGen, Allscripts, DrChrono via SMART-on-FHIR OAuth. This is the big one.
2. **Calendly** — webhook-based, trivial, covers a lot of small practices.
3. **Google Calendar** — for solo practitioners using gcal as a booking system.
4. **Jane App** — popular with allied health (PT, chiro, mental health). REST API.
5. **SimplePractice** — popular with mental health. They have a partner API.
6. **Acuity Scheduling (Squarespace)** — webhook-based.
7. **NexHealth** — they aggregate dental + medical PMS systems; one integration unlocks many.
8. **Generic CSV import + iCal feed** — fallback for anyone who doesn't fit above.
9. **Public REST API + webhook receiver** — for partners to push to us directly.

For each adapter, write a `*_adapter_spec.rb` with VCR cassettes. Stub credentials in `Rails.application.credentials.integrations.<name>`.

## 5. HIPAA guardrails

We are not yet covered by a BAA — note this prominently in the README and treat the codebase as if we will be. Concretely:

- **Encryption at rest** for `patients.first_name`, `patients.last_name`, `patients.phone`, `patients.date_of_birth`, `appointments.notes` via Lockbox. Blind indexes for phone + DOB so we can still look patients up.
- **Encryption in transit** — force SSL, HSTS, secure cookies.
- **No PHI in logs.** Lograge filter strips known PHI params. Add a `PhiFilter` middleware.
- **No PHI in SMS bodies.** Templates are linted at boot — any template containing `{{ last_name }}`, `{{ dob }}`, `{{ reason }}`, `{{ diagnosis }}` raises.
- **Audit log** every read and write of `Patient` and `Appointment` via the `audited` gem, scoped per tenant. Audits themselves are immutable.
- **Session timeout** 15 minutes of inactivity for staff.
- **Role-based access**: `owner`, `admin`, `front_desk`, `provider`. Front desk cannot export, providers cannot delete.
- **Data retention**: configurable per tenant, default purge of completed appointments after 7 years.
- **BAA reminder** banner in admin until tenant uploads signed BAA.
- **Twilio + Square accounts** must be HIPAA-eligible (Twilio offers a BAA on paid plans; Square does not currently sign BAAs, so gift card flow must NEVER include PHI — only a token + amount).

Document all of this in `docs/HIPAA.md` as we go.

## 6. UI/UX direction

This is the thing that has to feel different. No bootstrap-admin energy. No generic SaaS dashboard.

**Aesthetic:** calm, confident, medical-but-not-clinical. Think Linear meets a really nice physical therapy clinic. Generous whitespace. One accent color (a warm teal — `#0E9C8A`-ish, to be tuned). Soft shadows, never harsh borders. Rounded-2xl everywhere. System font stack with Inter as the primary.

**Mobile first, genuinely.** The staff dashboard is the primary surface and front desk staff are on their feet. Big tap targets (min 44px). Bottom-anchored primary actions on mobile. Swipe-to-check-in on the appointment row.

**Three core screens:**

1. **Today view** — vertical timeline of today's appointments. Each row shows time, patient first name + last initial, provider, status pill, and a primary action button. Live updates animate in via Turbo Streams. Color-coded status: scheduled (neutral), checked in (teal), in room (blue), running late (amber), no-show (gray), complete (green).

2. **Appointment detail / "running late" controls** — slide-up sheet on mobile, side panel on desktop. Big delay buttons (+5, +10, +15, +30 min) and a free-text note. Sending fires SMS immediately with optimistic UI. Shows SMS history with the patient.

3. **Patient status page** — what the patient sees when they tap the SMS link. Clean, no login. Shows: "You're checked in for your 2:30 appointment with Dr. Lee. Current wait: ~15 min. We'll text you 10 min before you're up." If a gift card has been issued, shows it inline with a "Redeem" button. Auto-refreshes via Turbo Stream subscription to a public channel keyed by signed appointment token.

**Components to build as ViewComponents:**
`StatusPill`, `AppointmentRow`, `TimelineMarker`, `DelayButton`, `SmsBubble`, `SheetPanel`, `EmptyState`, `Toast`, `BAABanner`.

**Icons:** Heroicons (already plays nice with Tailwind). No emoji in UI.

**Loading states:** every async action has a Stimulus controller that swaps to a skeleton or spinner. No dead clicks.

## 7. Domain model (sketch)

```
Tenant (practice)
  has_many :users (staff)
  has_many :providers
  has_many :patients
  has_many :appointments
  has_many :integrations
  has_one  :sms_settings
  has_one  :gift_card_settings

Provider
  belongs_to :tenant
  has_many :appointments

Patient (PHI — encrypted)
  belongs_to :tenant
  has_many :appointments
  has_many :sms_messages

Appointment
  belongs_to :tenant
  belongs_to :provider
  belongs_to :patient
  has_many :status_events
  has_many :sms_messages
  has_many :gift_cards
  enum status: { scheduled:, checked_in:, in_room:, running_late:, complete:, no_show:, canceled: }
  external_id (from integration)
  external_source (e.g. "fhir:epic", "calendly")
  signed_token (for patient status page URL)

StatusEvent
  belongs_to :appointment
  belongs_to :user (who made the change)
  from_status, to_status, delay_minutes, note, created_at

SmsMessage
  belongs_to :appointment
  belongs_to :patient
  direction (in/out), body, twilio_sid, delivered_at

GiftCard
  belongs_to :appointment
  belongs_to :tenant
  square_gan, amount_cents, merchant_name, merchant_url, issued_at, redeemed_at

Integration
  belongs_to :tenant
  type (STI: FhirIntegration, CalendlyIntegration, ...)
  encrypted credentials, last_synced_at, status

AuditLog (via `audited` gem)
```

## 8. Build order

Stop after each milestone, summarize, and wait for approval.

1. **Bootstrap** — `rails new schedulite -d postgresql -c tailwind -j esbuild`, add gems, set up RSpec, Sidekiq, Lockbox, acts_as_tenant. Commit.
2. **Tenants + staff auth** — Tenant model, Devise install, role enum, session timeout, basic sign-in screen styled to spec.
3. **Domain models + migrations** — Patient (encrypted), Provider, Appointment, StatusEvent, SmsMessage, GiftCard. Factories + model specs.
4. **Today view (read-only)** — seed sample data, build the timeline UI as ViewComponents, mobile-first Tailwind, no interactivity yet. This is where you prove the UI direction.
5. **Check-in + status changes** — Stimulus controllers, Turbo Stream broadcasts, StatusEvent recording, audit log wired up.
6. **Twilio integration** — SMS service object, templates with PHI lint, outbound sending on status changes, inbound webhook for replies. Use Twilio test credentials.
7. **Patient status page** — signed URL, public controller, Turbo Stream subscription, auto-refresh.
8. **Square gift card flow** — settings UI, threshold trigger, Square Sandbox integration, redeem flow.
9. **Integrations framework** — `Integrations::Adapter` base, sync job, webhook receiver controller, settings UI to connect/disconnect.
10. **FHIR adapter** — SMART-on-FHIR OAuth dance, fetch appointments, map to internal model. Test against the public Epic sandbox.
11. **Calendly adapter** — webhook-based, fastest second integration.
12. **Google Calendar adapter**.
13. **Jane App, SimplePractice, Acuity, NexHealth adapters** — in that order, one per session.
14. **Public API + API key auth** — `/api/v1/appointments`, webhook out for status changes.
15. **HIPAA hardening pass** — re-audit per `docs/HIPAA.md`, add the BAA banner, run Brakeman + bundler-audit.
16. **Polish pass** — empty states, error states, loading skeletons, dark mode, accessibility audit (axe), Lighthouse mobile score >= 95.
17. **Deployment docs** — Fly.io or Render, Postgres + Redis, env vars, Sidekiq worker, how to point a domain.

## 9. Conventions

- Service objects in `app/services/`, one class per file, `call` as the entry point.
- Jobs in `app/jobs/`, idempotent, retry-safe.
- Controllers stay thin — no business logic.
- ViewComponents over partials for anything reused.
- Tailwind classes in views; no `@apply` except in `application.css` for typographic resets.
- Tests: model specs for validations + scopes, request specs for controllers, system specs for the 3 core screens, VCR for integrations.
- Commits: conventional commits (`feat:`, `fix:`, `chore:`), one logical change per commit.

## 10. Open questions to surface as we go

- Which FHIR sandbox to develop against first (Epic vs SMART Health IT public sandbox)?
- Do we want Twilio Verify for staff 2FA, or TOTP via devise-two-factor?
- Square gift card UX: pre-purchased pool per practice, or on-demand purchase per incident?
- Should the patient status page support adding the appointment to Apple/Google Wallet?

Surface these as GitHub issues, don't decide unilaterally.
