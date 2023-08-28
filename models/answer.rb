class Answer < ActiveRecord::Base
  belongs_to :question, polymorphic: true
  has_many :question_answers
  has_many :questions, through: :question_answers
  #indicacion a active record para que reconozca la columna como arreglo
  serialize :answers_autocomplete, JSON

  validates :question_id, presence: true
  validates :text, presence: true, unless: :autocomplete_question?
  validates :correct, inclusion: { in: [true, false] }, unless: :autocomplete_question?
  validates :text, length: { maximum: 255 }, unless: :autocomplete_question?

  private

  def autocomplete_question?
    # Verifica si la pregunta asociada es de tipo Autocomplete
    question.is_a?(Autocomplete)
  end
end
