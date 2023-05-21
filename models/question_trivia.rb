class QuestionTrivia < ActiveRecord::Base
  self.table_name = 'questions_trivias'
  belongs_to :trivia
  belongs_to :question
end
