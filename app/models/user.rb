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

  def self.find_or_create_by_email(email)
    email = 'anon@afdc.com' if email.blank?
    user  = User.find_by_email(email.downcase)
    unless user
      user = User.new({email: email.downcase, crypted_password: '', salt: ''})
      user.save(validate: false) # Otherwise password checks will fail
    end

    return user
  end

  private

  def downcase_email
    email = email.downcase
  end
end
