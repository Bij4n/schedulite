class CreateProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :providers do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :title

      t.timestamps
    end
  end
end
