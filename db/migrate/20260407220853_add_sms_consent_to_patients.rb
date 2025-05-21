class AddSmsConsentToPatients < ActiveRecord::Migration[8.1]
  def change
    add_column :patients, :sms_consent, :boolean, default: true
    add_column :patients, :sms_opted_out_at, :datetime
  end
end
