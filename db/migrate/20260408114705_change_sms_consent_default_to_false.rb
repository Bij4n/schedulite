class ChangeSmsConsentDefaultToFalse < ActiveRecord::Migration[8.1]
  def change
    change_column_default :patients, :sms_consent, from: true, to: false
  end
end
