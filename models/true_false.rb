class True_False < ActiveRecord::Base
  # Relación con la tabla de preguntas
  belongs_to :question

  #Relacion con respuesta
  has_many :answers

  validate :must_have_two_answers

  private

  def must_have_two_answers
    errors.add(:answers, "must have exactly 2 answers") unless answers.size == 2
  end
end
