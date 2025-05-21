class CreatePatientFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :patient_feedbacks do |t|
      t.references :appointment, null: false, foreign_key: true
      t.references :patient, null: false, foreign_key: true
      t.integer :rating
      t.text :comment

      t.timestamps
    end
  end
end
