class CreateSmsMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :sms_messages do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.integer :direction, null: false
      t.text :body, null: false
      t.string :twilio_sid
      t.datetime :delivered_at

      t.timestamps
    end
  end
end
