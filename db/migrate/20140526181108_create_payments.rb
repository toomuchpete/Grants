class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :public_id, index: true
      t.decimal :amount, precision: 8, scale: 2
      t.hstore :web_request
      t.hstore :merchant_details

      t.timestamps
    end
  end
end
