# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_09_014226) do
  create_table "api_keys", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key_digest"
    t.datetime "last_used_at"
    t.string "name"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_api_keys_on_tenant_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "delay_minutes"
    t.integer "duration_minutes", default: 30
    t.datetime "ends_at"
    t.string "external_id"
    t.string "external_source"
    t.text "notes_ciphertext"
    t.integer "patient_id", null: false
    t.integer "provider_id", null: false
    t.string "signed_token"
    t.datetime "starts_at", null: false
    t.integer "status", default: 0, null: false
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["external_source", "external_id"], name: "index_appointments_on_external_source_and_external_id"
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
    t.index ["provider_id"], name: "index_appointments_on_provider_id"
    t.index ["signed_token"], name: "index_appointments_on_signed_token", unique: true
    t.index ["tenant_id", "starts_at"], name: "index_appointments_on_tenant_id_and_starts_at"
    t.index ["tenant_id"], name: "index_appointments_on_tenant_id"
  end

  create_table "audits", force: :cascade do |t|
    t.string "action"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "auditable_id"
    t.string "auditable_type"
    t.text "audited_changes"
    t.string "comment"
    t.datetime "created_at"
    t.string "remote_address"
    t.string "request_uuid"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.integer "version", default: 0
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id", "version"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "gift_card_settings", force: :cascade do |t|
    t.integer "amount_cents"
    t.datetime "created_at", null: false
    t.integer "delay_threshold_minutes"
    t.string "merchant_name"
    t.string "merchant_url"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_gift_card_settings_on_tenant_id"
  end

  create_table "gift_cards", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.integer "appointment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "issued_at"
    t.string "merchant_name"
    t.string "merchant_url"
    t.datetime "redeemed_at"
    t.string "square_gan"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_gift_cards_on_appointment_id"
    t.index ["tenant_id"], name: "index_gift_cards_on_tenant_id"
  end

  create_table "integrations", force: :cascade do |t|
    t.string "adapter_type", null: false
    t.datetime "created_at", null: false
    t.text "credentials_ciphertext"
    t.datetime "last_synced_at"
    t.integer "provider_id"
    t.string "status"
    t.text "sync_error"
    t.datetime "sync_error_at"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["provider_id"], name: "index_integrations_on_provider_id"
    t.index ["tenant_id"], name: "index_integrations_on_tenant_id"
    t.index ["user_id"], name: "index_integrations_on_user_id"
  end

  create_table "login_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id"
    t.index ["user_id"], name: "index_login_events_on_user_id"
  end

  create_table "no_show_charges", force: :cascade do |t|
    t.integer "amount_cents", null: false
    t.integer "appointment_id", null: false
    t.datetime "created_at", null: false
    t.integer "patient_id", null: false
    t.string "status", default: "pending", null: false
    t.string "stripe_charge_id"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_no_show_charges_on_appointment_id"
    t.index ["patient_id"], name: "index_no_show_charges_on_patient_id"
    t.index ["tenant_id"], name: "index_no_show_charges_on_tenant_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "email_enabled"
    t.string "event_name"
    t.boolean "sms_enabled"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_notification_preferences_on_tenant_id"
  end

  create_table "patient_feedbacks", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.integer "patient_id", null: false
    t.integer "rating"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_patient_feedbacks_on_appointment_id"
    t.index ["patient_id"], name: "index_patient_feedbacks_on_patient_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "card_brand"
    t.string "card_last4"
    t.datetime "created_at", null: false
    t.string "date_of_birth_bidx"
    t.text "date_of_birth_ciphertext"
    t.string "email_bidx"
    t.text "email_ciphertext"
    t.text "first_name_ciphertext"
    t.text "last_name_ciphertext"
    t.string "phone_bidx"
    t.text "phone_ciphertext"
    t.integer "primary_provider_id"
    t.boolean "sms_consent", default: false
    t.datetime "sms_opted_out_at"
    t.text "stripe_customer_id_ciphertext"
    t.text "stripe_payment_method_id_ciphertext"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["date_of_birth_bidx"], name: "index_patients_on_date_of_birth_bidx"
    t.index ["email_bidx"], name: "index_patients_on_email_bidx"
    t.index ["phone_bidx"], name: "index_patients_on_phone_bidx"
    t.index ["primary_provider_id"], name: "index_patients_on_primary_provider_id"
    t.index ["tenant_id"], name: "index_patients_on_tenant_id"
  end

  create_table "provider_schedules", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.time "end_time"
    t.string "lunch_end"
    t.string "lunch_start"
    t.text "notes"
    t.integer "proposed_by_id"
    t.integer "provider_id", null: false
    t.integer "slot_duration_minutes"
    t.time "start_time"
    t.string "status", default: "draft"
    t.datetime "updated_at", null: false
    t.index ["proposed_by_id"], name: "index_provider_schedules_on_proposed_by_id"
    t.index ["provider_id"], name: "index_provider_schedules_on_provider_id"
  end

  create_table "providers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "tenant_id", null: false
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_providers_on_tenant_id"
  end

  create_table "recurring_appointments", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.integer "duration_minutes"
    t.integer "patient_id", null: false
    t.integer "provider_id", null: false
    t.string "recurrence_rule"
    t.time "starts_at_time"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_recurring_appointments_on_patient_id"
    t.index ["provider_id"], name: "index_recurring_appointments_on_provider_id"
    t.index ["tenant_id"], name: "index_recurring_appointments_on_tenant_id"
  end

  create_table "sms_messages", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "delivered_at"
    t.integer "direction", null: false
    t.integer "patient_id", null: false
    t.string "twilio_sid"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_sms_messages_on_appointment_id"
    t.index ["patient_id"], name: "index_sms_messages_on_patient_id"
  end

  create_table "staff_shifts", force: :cascade do |t|
    t.integer "break_minutes", default: 30
    t.datetime "created_at", null: false
    t.integer "day_of_week", null: false
    t.string "end_time", null: false
    t.string "start_time", null: false
    t.string "status", default: "proposed", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_staff_shifts_on_user_id"
  end

  create_table "status_events", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.datetime "created_at", null: false
    t.integer "delay_minutes"
    t.string "from_status"
    t.text "note"
    t.string "to_status", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["appointment_id"], name: "index_status_events_on_appointment_id"
    t.index ["user_id"], name: "index_status_events_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "baa_uploaded_at"
    t.datetime "created_at", null: false
    t.integer "data_retention_years", default: 7
    t.integer "default_break_minutes", default: 30
    t.string "default_shift_end", default: "17:00"
    t.string "default_shift_start", default: "09:00"
    t.string "lunch_end"
    t.string "lunch_start"
    t.integer "max_hours_per_week", default: 40
    t.string "name", null: false
    t.integer "no_show_fee_cents"
    t.string "plan", default: "free"
    t.integer "required_lunch_minutes", default: 30
    t.string "stripe_customer_id"
    t.string "subdomain", null: false
    t.datetime "trial_ends_at"
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
  end

  create_table "time_entries", force: :cascade do |t|
    t.integer "break_minutes_taken"
    t.datetime "clock_in_at"
    t.datetime "clock_out_at"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.text "notes"
    t.string "status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_time_entries_on_user_id"
  end

  create_table "time_off_requests", force: :cascade do |t|
    t.integer "approved_by_id"
    t.datetime "created_at", null: false
    t.date "end_date", null: false
    t.text "reason"
    t.string "request_type", default: "pto", null: false
    t.datetime "responded_at"
    t.date "start_date", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["approved_by_id"], name: "index_time_off_requests_on_approved_by_id"
    t.index ["user_id"], name: "index_time_off_requests_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 2, null: false
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["tenant_id"], name: "index_users_on_tenant_id"
  end

  create_table "webhook_subscriptions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "events"
    t.string "secret_digest"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.index ["tenant_id"], name: "index_webhook_subscriptions_on_tenant_id"
  end

  add_foreign_key "api_keys", "tenants"
  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "providers"
  add_foreign_key "appointments", "tenants"
  add_foreign_key "gift_card_settings", "tenants"
  add_foreign_key "gift_cards", "appointments"
  add_foreign_key "gift_cards", "tenants"
  add_foreign_key "integrations", "providers"
  add_foreign_key "integrations", "tenants"
  add_foreign_key "integrations", "users"
  add_foreign_key "login_events", "users"
  add_foreign_key "no_show_charges", "appointments"
  add_foreign_key "no_show_charges", "patients"
  add_foreign_key "no_show_charges", "tenants"
  add_foreign_key "notification_preferences", "tenants"
  add_foreign_key "patient_feedbacks", "appointments"
  add_foreign_key "patient_feedbacks", "patients"
  add_foreign_key "patients", "providers", column: "primary_provider_id"
  add_foreign_key "patients", "tenants"
  add_foreign_key "provider_schedules", "providers"
  add_foreign_key "provider_schedules", "users", column: "proposed_by_id"
  add_foreign_key "providers", "tenants"
  add_foreign_key "recurring_appointments", "patients"
  add_foreign_key "recurring_appointments", "providers"
  add_foreign_key "recurring_appointments", "tenants"
  add_foreign_key "sms_messages", "appointments"
  add_foreign_key "sms_messages", "patients"
  add_foreign_key "staff_shifts", "users"
  add_foreign_key "status_events", "appointments"
  add_foreign_key "status_events", "users"
  add_foreign_key "time_entries", "users"
  add_foreign_key "time_off_requests", "users"
  add_foreign_key "time_off_requests", "users", column: "approved_by_id"
  add_foreign_key "users", "tenants"
  add_foreign_key "webhook_subscriptions", "tenants"
end
