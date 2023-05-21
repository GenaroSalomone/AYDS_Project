class Difficulty < ActiveRecord::Base
  extend Enumerize
  has_many :trivias
  has_many :questions

  enumerize :level, in: [:beginner, :difficult], default: :beginner
end
