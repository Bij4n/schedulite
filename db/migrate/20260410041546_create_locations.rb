class CreateLocations < ActiveRecord::Migration[8.1]
  def change
    create_table :locations do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.decimal :latitude
      t.decimal :longitude
      t.string :lunch_start
      t.string :lunch_end
      t.integer :no_show_fee_cents

      t.timestamps
    end
  end
end
