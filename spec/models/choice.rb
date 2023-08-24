class Choice < Question
  has_many :question_answers
  has_many :answers, as: :question, through: :question_answers
  belongs_to :difficulty
  validates :text, presence: true
  validates :difficulty_id, presence: true
end
