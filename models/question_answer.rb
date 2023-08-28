# permite asociar múltiples respuestas a una pregunta y rastrear las respuestas seleccionadas por los usuarios en cada pregunta
class QuestionAnswer < ActiveRecord::Base
  self.table_name = 'question_answers'
  belongs_to :question
  belongs_to :answer
  belongs_to :trivia

  validates :question_id, uniqueness: { scope: [:answer_id, :trivia_id] }

  validate :consistent_difficulty
  validate :consistent_combination

  private

  def consistent_combination
    if question_id.blank? || answer_id.blank? || trivia_id.blank?
      errors.add(:base, "Question, answer, and trivia must be present")
    end
  end

  private

  def consistent_difficulty
    if question && answer && trivia
      unless question.difficulty.level == trivia.difficulty.level
        errors.add(:base, "Question and trivia must have the same difficulty")
      end
    end
  end

end
