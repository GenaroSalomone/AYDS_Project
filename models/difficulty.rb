class Difficulty < ActiveRecord::Base
  extend Enumerize
  has_many :trivias
  has_many :questions
  has_many :choices
  has_many :true_falses
  has_many :autocompletes

  enumerize :level, in: [:beginner, :difficult], default: :beginner
end
