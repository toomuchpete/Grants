class CreatePurchases < ActiveRecord::Migration
  def change
    create_table :purchases do |t|
      t.decimal :price, precision: 8, scale: 2
      t.hstore :item_details
      t.text :shipping_address
      t.text :comments

      t.belongs_to :user, index: true
      t.timestamps
    end

    create_table :purchase_line_items do |t|
      t.integer :quantity
      t.decimal :unit_price, precision: 8, scale: 2
      t.belongs_to :purchase, index: true
      t.belongs_to :product, index: true
      t.timestamps
    end
  end
end
