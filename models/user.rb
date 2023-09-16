class User < ActiveRecord::Base
  validates :username, uniqueness: true, presence: true
  validates :email, uniqueness: true, presence: true
  validates :password, presence: true
  has_many :trivias
  has_many :rankings
  has_many :claims
  has_secure_password
end



