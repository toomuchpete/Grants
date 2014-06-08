class Purchase < ActiveRecord::Base
  belongs_to :user
  has_many :purchase_line_items
  has_many :products, through: :purchase_line_items
end
