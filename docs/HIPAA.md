# HIPAA Security Controls

Schedulite is designed to be HIPAA-ready. This document inventories the security controls in place. A signed Business Associate Agreement (BAA) is required before handling real patient data in production.

## Status

**BAA Status:** Not yet signed. A banner is displayed in the admin interface until a BAA is uploaded.

## Protected Health Information (PHI)

### What constitutes PHI in Schedulite

| Field | Model | Storage |
|-------|-------|---------|
| Patient first name | `Patient` | Lockbox encrypted (`first_name_ciphertext`) |
| Patient last name | `Patient` | Lockbox encrypted (`last_name_ciphertext`) |
| Patient phone number | `Patient` | Lockbox encrypted (`phone_ciphertext`) + blind index |
| Patient date of birth | `Patient` | Lockbox encrypted (`date_of_birth_ciphertext`) + blind index |
| Appointment notes | `Appointment` | Lockbox encrypted (`notes_ciphertext`) |
| Integration credentials | `Integration` | Lockbox encrypted (`credentials_ciphertext`) |

### Encryption at Rest

- **Method:** Lockbox gem with AES-256-GCM encryption
- **Key management:** Single master key via `LOCKBOX_MASTER_KEY` environment variable
- **Blind indexes:** Phone and date of birth have blind indexes (HMAC-based) for lookups without decrypting all records
- **Database:** Encrypted columns store ciphertext only — raw database access reveals no PHI

### Encryption in Transit

- **Force SSL:** `config.force_ssl = true` in production
- **HSTS:** Strict-Transport-Security headers enabled
- **Secure cookies:** Session cookies marked `secure` and `httponly`

## Access Controls

### Authentication

- Devise with email/password
- Session timeout: 15 minutes of inactivity (`:timeoutable` module)
- Optional 2FA via `devise-two-factor` (TOTP)

### Role-Based Access

| Role | Permissions |
|------|------------|
| `owner` | Full access, manage staff, manage integrations, export data |
| `admin` | Manage staff, manage integrations, view audit logs |
| `front_desk` | Check in patients, update statuses, view today's schedule. Cannot export data. |
| `provider` | View own appointments, update statuses. Cannot delete records. |

### Multi-Tenancy

- Row-level isolation via `acts_as_tenant`
- All queries automatically scoped to current tenant
- Cross-tenant access returns 404 (not 403, to prevent enumeration)

## Audit Logging

- **Gem:** `audited`
- **Scope:** All reads and writes to `Patient` and `Appointment` models
- **Content:** User who made the change, timestamp, old/new values
- **Immutability:** Audit records cannot be modified or deleted
- **Exclusions:** Encrypted ciphertext columns are excluded from audit diffs (they would show gibberish)
- **Tenant scoping:** Audits are associated with the acting user's tenant

## SMS Safety

### PHI in SMS Bodies

**Rule: No PHI in SMS bodies. Ever.**

Allowed in SMS:
- Patient first name
- Appointment time
- Delay duration (minutes)
- Status page URL (signed token, no PHI in URL)

Prohibited in SMS:
- Last name
- Date of birth
- Diagnosis or reason for visit
- Provider specialty
- Insurance information

### Enforcement

- `SmsTemplate` class defines all SMS templates with string interpolation
- `SmsTemplate.lint!` runs at application boot and raises `PhiLeakError` if any template contains prohibited placeholders (`%{last_name}`, `%{dob}`, `%{date_of_birth}`, `%{diagnosis}`, `%{reason}`, `%{provider_specialty}`)
- Templates are tested in `spec/services/sms_template_spec.rb`

### Twilio BAA

Twilio offers a BAA on paid plans. The Twilio account used for production must have a signed BAA if handling real PHI. Configure via Twilio's Trust Center.

## Third-Party Services

### Square (Gift Cards)

Square does **not** currently sign BAAs. Therefore:
- Gift card API calls contain **only** an idempotency key (appointment ID hash) and a dollar amount
- No patient name, phone, DOB, or any PHI is ever sent to Square
- This is enforced in `GiftCardIssuanceService` and verified in specs

### Sentry (Error Tracking)

- Sentry SDK is configured but PHI must be scrubbed from error reports
- `filter_parameter_logging.rb` strips PHI params from logs
- Lograge custom options strip PHI fields from request logs

## Log Safety

### Parameter Filtering

The following parameters are filtered from all Rails logs:

```ruby
:first_name, :last_name, :phone, :date_of_birth, :dob,
:diagnosis, :reason, :notes
```

Plus standard sensitive fields: `:passw`, `:email`, `:secret`, `:token`, `:_key`, `:crypt`, `:salt`, `:certificate`, `:otp`, `:ssn`, `:cvv`, `:cvc`

### Lograge

Structured JSON logging via Lograge. Custom options filter any parameter matching PHI field names from request logs.

## Data Retention

- Default retention period: 7 years for completed appointments (configurable per tenant)
- Audit logs are never purged
- Patient records are retained as long as they have active appointments within the retention window

## Incident Response

If a PHI breach is suspected:

1. Immediately revoke the `LOCKBOX_MASTER_KEY` and rotate to a new key
2. Review audit logs for unauthorized access patterns
3. Notify affected tenants within 24 hours
4. Follow HIPAA Breach Notification Rule (45 CFR 164.400-414)
5. Document the incident, scope, and remediation steps

## Security Testing

- **Brakeman:** Static analysis for security vulnerabilities (`bundle exec brakeman`)
- **bundler-audit:** Dependency vulnerability scanning (`bundle exec bundler-audit`)
- **RSpec:** PHI lint tests, encryption verification, access control tests
- **Manual:** Verify PHI is not visible in database console, logs, or error reports
