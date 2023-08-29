class Ranking < ActiveRecord::Base
  belongs_to :user
  belongs_to :trivia
  belongs_to :difficulty
  validates :user_id, presence: true
  validates :difficulty_id, presence: true
  validates :score, presence: true
end
