class CreateDonations < ActiveRecord::Migration
  def change
    create_table :donations do |t|
      t.decimal :amount, precision: 8, scale: 2
      t.belongs_to :user, index: true
      t.text :comments
      t.text :internal_notes

      t.timestamps
    end
  end
end
