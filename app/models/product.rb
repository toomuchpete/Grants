class Product < ActiveRecord::Base
  has_attached_file :image, :styles => { big: '325x325>', medium: "200x200>", thub: "100x100>" }, :default_url => "/images/missing.jpg"
  has_many :purchase_line_items
  has_many :purchases, through: :purchase_line_items
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  def purchaseable?
    true
  end
end
