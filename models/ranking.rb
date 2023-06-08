class Ranking < ActiveRecord::Base
  belongs_to :user
  belongs_to :trivia
  belongs_to :difficulty
end
