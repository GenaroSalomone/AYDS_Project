# permite asociar múltiples respuestas a una pregunta y rastrear las respuestas seleccionadas por los usuarios en cada pregunta
class QuestionAnswer < ActiveRecord::Base
  self.table_name = 'question_answers'
  belongs_to :question
  belongs_to :answer
  belongs_to :trivia
end
