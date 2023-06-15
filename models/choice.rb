class Choice < Question
  has_many :question_answers
  has_many :answers, as: :question, through: :question_answers
  belongs_to :difficulty
  
  # Validaciones para las pruebas
  validates :text, presence: true
  validates :difficulty_id, presence: true
end
