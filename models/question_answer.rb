# permite asociar múltiples respuestas a una pregunta y rastrear las respuestas seleccionadas por los usuarios en cada pregunta
class QuestionAnswer < ActiveRecord::Base
  self.table_name = 'question_answers'
  belongs_to :question
  belongs_to :answer
  belongs_to :trivia

  #no puede haber tuplas iguales con question_id, answer_id, trivia_id
  validates :question_id, uniqueness: { scope: [:answer_id, :trivia_id] }
  validate :consistent_combination
  validate :consistent_difficulty

  private

  #una question answer debe tener el mismo nivel de dificultad para la question y la trivia
  def consistent_difficulty
    if question && trivia
      unless question.difficulty.level == trivia.difficulty.level
        errors.add(:base, "Question and trivia must have the same difficulty")
      end
    end
  end

  private

  #una question answer no puede tener nil en question y trivia simultaneamente
  def consistent_combination
    if question.blank? || trivia.blank?
      errors.add(:base, "Question, answer, and trivia must be present")
    end
  end
end
