class Payment < ActiveRecord::Base
  before_create :assign_public_id

  private

  def assign_public_id
    self.public_id = SecureRandom.uuid unless self.public_id
  end
end
