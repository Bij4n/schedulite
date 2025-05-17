class CreateWebhookSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :webhook_subscriptions do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :url
      t.string :secret_digest
      t.string :events

      t.timestamps
    end
  end
end
