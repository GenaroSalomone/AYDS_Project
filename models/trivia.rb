class Trivia < ActiveRecord::Base
  self.table_name = "trivias"
  has_many :question_trivias
  has_many :questions, through: :question_trivias
  belongs_to :user
  belongs_to :difficulty
end
