class Choice < Question

  #Relacion con respuesta
  has_many :answers, foreign_key: 'choice_id'

  validate :must_have_four_answers

  private

  def must_have_four_answers
    errors.add(:answers, "must have exactly 4 answers") if answers.size != 4
  end
end
