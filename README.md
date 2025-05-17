# Schedulite

Real-time appointment check-in and wait-time communication platform for medical practices. Patients book through whatever system the practice already uses — Schedulite ingests those appointments, lets front-desk staff check patients in, and pushes live SMS updates as wait times change.

**Note:** This application is designed to be HIPAA-ready but is not yet covered by a Business Associate Agreement (BAA). See `docs/HIPAA.md` for details on the security controls in place.

## Features

- **Multi-tenant** — one practice per tenant, row-level data isolation via `acts_as_tenant`
- **Staff dashboard** — mobile-first Today View with real-time Turbo Stream updates
- **Check-in flow** — tap to check in, status transitions with full audit trail
- **SMS notifications** — check-in confirmation, delay notices, "you're next" alerts via Twilio
- **Patient status page** — public, no-login page accessed via signed URL in SMS
- **Gift card goodwill** — automatic Square gift card issuance when delays exceed a configurable threshold
- **EHR integrations** — FHIR R4 adapter covers Epic, Athena, Cerner, and more. Extensible adapter interface for Calendly, Google Calendar, Jane App, etc.
- **PHI protection** — Lockbox encryption at rest, blind indexes for lookups, PHI-linted SMS templates, audit logging on all patient/appointment access

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Ruby on Rails 8.1 |
| Database | SQLite (dev/test), PostgreSQL (production) |
| Background Jobs | Sidekiq + Redis |
| Real-time | Hotwire (Turbo Streams + Stimulus) over ActionCable |
| CSS | Tailwind CSS v4 |
| Components | ViewComponent |
| Auth | Devise (email/password, 15-min session timeout, role-based access) |
| Encryption | Lockbox + blind_index (column-level encryption for PHI) |
| Audit | audited gem (immutable audit log) |
| SMS | Twilio |
| Gift Cards | Square API |
| EHR | FHIR R4 via custom HTTP adapter |
| Testing | RSpec, FactoryBot, Shoulda Matchers, WebMock |

## Prerequisites

- Ruby 3.2+
- Node.js 18+
- Redis (for ActionCable and Sidekiq)
- SQLite3 (development) or PostgreSQL 16 (production)

## Setup

```bash
# Clone and install dependencies
git clone git@github.com:Bij4n/schedulite.git
cd schedulite
bundle install
npm install

# Configure encryption key
export LOCKBOX_MASTER_KEY=$(ruby -e "require 'securerandom'; puts SecureRandom.hex(32)")

# Create and seed the database
bin/rails db:create db:migrate db:seed

# Build assets
npm run build
npm run build:css

# Start the development server
bin/dev
```

After seeding, sign in at `http://localhost:3000` with:
- **Email:** `maria@sunrise.example.com`
- **Password:** `password123!`

## Running Tests

```bash
bundle exec rspec
```

The test suite includes model specs, request specs, service specs, job specs, and ViewComponent specs. All PHI encryption and audit logging is verified in tests.

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `LOCKBOX_MASTER_KEY` | Yes | 64-char hex key for Lockbox column encryption |
| `REDIS_URL` | No | Redis connection URL (default: `redis://localhost:6379/0`) |
| `APP_HOST` | No | Base URL for links in SMS messages (default: `http://localhost:3000`) |

### Twilio (for SMS)

Configure via Rails credentials (`bin/rails credentials:edit`):

```yaml
twilio:
  account_sid: AC...
  auth_token: ...
  phone_number: "+15550001234"
```

### Square (for gift cards)

```yaml
square:
  access_token: ...
  location_id: ...
```

## Architecture

### Domain Model

```
Tenant (practice)
├── Users (staff: owner, admin, front_desk, provider)
├── Providers
├── Patients (encrypted: name, phone, DOB)
├── Appointments
│   ├── StatusEvents (audit trail)
│   ├── SmsMessages (inbound/outbound)
│   └── GiftCards
├── Integrations (encrypted credentials)
└── GiftCardSettings
```

### Integrations

All integrations implement `Integrations::Adapter`:

```ruby
module Integrations
  class Adapter
    def fetch_appointments(date_range:); end   # returns [AppointmentDTO]
    def push_status(appointment_id:, status:); end
    def supports_webhooks?; end
    def verify_webhook(request); end
    def parse_webhook(payload); end            # returns AppointmentDTO
  end
end
```

Adding a new integration:
1. Create `app/services/integrations/foo_adapter.rb` extending `Adapter`
2. Register in `Integrations::AdapterFactory::ADAPTERS`
3. Write specs with WebMock stubs

### Key Service Objects

- `StatusChangeService` — orchestrates check-in, status transitions, StatusEvent creation
- `SmsService` — renders PHI-safe templates and sends via Twilio
- `SmsTemplate` — template definitions with boot-time PHI lint
- `GiftCardIssuanceService` — issues Square gift cards when delay threshold exceeded
- `SquareClient` — thin HTTP wrapper for Square Gift Cards API

## Deployment

See `docs/DEPLOYMENT.md` for detailed deployment instructions covering Fly.io/Render, PostgreSQL, Redis, Sidekiq, and domain configuration.

## License

Proprietary. All rights reserved.
