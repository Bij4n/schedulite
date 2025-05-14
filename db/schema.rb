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

ActiveRecord::Schema[8.1].define(version: 2026_04_07_124743) do
  create_table "appointments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "delay_minutes"
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
    t.string "status"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_integrations_on_tenant_id"
  end

  create_table "patients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "date_of_birth_bidx"
    t.text "date_of_birth_ciphertext"
    t.text "first_name_ciphertext"
    t.text "last_name_ciphertext"
    t.string "phone_bidx"
    t.text "phone_ciphertext"
    t.integer "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["date_of_birth_bidx"], name: "index_patients_on_date_of_birth_bidx"
    t.index ["phone_bidx"], name: "index_patients_on_phone_bidx"
    t.index ["tenant_id"], name: "index_patients_on_tenant_id"
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
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_tenants_on_subdomain", unique: true
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

  add_foreign_key "appointments", "patients"
  add_foreign_key "appointments", "providers"
  add_foreign_key "appointments", "tenants"
  add_foreign_key "gift_cards", "appointments"
  add_foreign_key "gift_cards", "tenants"
  add_foreign_key "integrations", "tenants"
  add_foreign_key "patients", "tenants"
  add_foreign_key "providers", "tenants"
  add_foreign_key "sms_messages", "appointments"
  add_foreign_key "sms_messages", "patients"
  add_foreign_key "status_events", "appointments"
  add_foreign_key "status_events", "users"
  add_foreign_key "users", "tenants"
end
