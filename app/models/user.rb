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
  # allow blank added so users can update profile without changing password
  # has_secure_password has a seperate presence validation that will catch blank password on new record creation
  # allow_blank is letting me enter blank passwords although the book claims to prevent it due to has_secure_password
  # book says it doesnt prevent "      " passwords using the has_secure_password validation
  validates :password, presence: true, length: { minimum: 6 }, allow_blank: true

  attr_accessor :remember_token

  # Returns the hash digest of the given string
  def User.digest(string)
    # cost is how computationally difficult the hash is to decrypt
    # low cost for tests
    # high cost for production
    # elvis notation for if else
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # returns a new random token to be used for cookies
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # remembers a use in the database for use in persistence sessions
  def remember
    self.remember_token = User.new_token
    # remember_digest is a column on the model (see the migration to double check)
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # forgets a user
  def forget
    update_attribute(:remember_digest, nil)
  end

  # returns true if the given token matches the digest
  def authenticated?(remember_token)
    remember_digest && BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

end
