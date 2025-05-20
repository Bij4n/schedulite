class CreateLoginEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :login_events do |t|
      t.references :user, null: true, foreign_key: true
      t.string :event_type, null: false
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
  end
end
