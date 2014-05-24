class User < ActiveRecord::Base
  authenticates_with_sorcery!
  serialize :roles, Array

  validates :password, presence: true,
                       confirmation: true,
                       length: { minimum: 6 },
                       on: :create

  validates :email, uniqueness: true, case_sensitive: false

  def role_symbols
    roles.map(&:to_sym)
  end

  private

  def downcase_email
    email = email.downcase
  end
end
