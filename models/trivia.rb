class Trivia < ActiveRecord::Base
  self.table_name = "trivias"
  has_many :question_answers
  has_many :questions, through: :question_answers
  belongs_to :user
  belongs_to :difficulty
end
