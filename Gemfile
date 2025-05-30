source "https://rubygems.org"

gem "rails", "~> 8.1.3"
gem "propshaft"
gem "pg", "~> 1.1", group: :production
gem "sqlite3"
gem "puma", ">= 5.0"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "redis"
gem "sidekiq"

# Authentication & authorization
gem "devise"
gem "devise-two-factor"

# Multi-tenancy
gem "acts_as_tenant"

# PHI encryption
gem "lockbox"
gem "blind_index"

# Audit logging
gem "audited"

# UI components
gem "view_component"

# Logging & monitoring
gem "lograge"
gem "sentry-ruby"
gem "sentry-rails"

# Integrations (wired up in later sprints)
gem "twilio-ruby"
# gem "square.rb" # TODO: enable when deploying with native extension support
gem "fhir_client"
gem "rack-attack"
gem "stripe"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "vcr"
  gem "webmock"
end
