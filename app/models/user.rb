class User < ApplicationRecord

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  # This is a callback that gets invoked before_save
  # before_save { self.email = email.downcase } this is equivalent to the below, ! means it changes the email value (said as bang in rails)
  before_save { email.downcase! }

  # :name = the symbol name
  # presence = cannot be blank
  # validates is a method, equivalent = validates(:name, presence: true)
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, 
                    length: { maximum: 255 }, 
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false} # database index should be used still to prevent duplication in database

  # requires password_digest in the user model to be defined
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  # Returns the hash digest of the given string
  def User.digest(string)
    # cost is how computationally difficult the hash is to decrypt
    # low cost for tests
    # high cost for production
    # elvis notation for if else
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

end
