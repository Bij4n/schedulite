class CreateNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preferences do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :event_name
      t.boolean :sms_enabled
      t.boolean :email_enabled

      t.timestamps
    end
  end
end
