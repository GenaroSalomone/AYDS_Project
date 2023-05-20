class User < ActiveRecord::Base
  validates :username, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :password, presence: true
  #has_secure_password
end



