class Question < ActiveRecord::Base
  has_many :question_answers
  has_many :answers, through: :question_answers
  belongs_to :difficulty
end


