class Choice < Question
  has_many :question_answers
  has_many :answers, as: :question, through: :question_answers
  belongs_to :difficulty
  validates_presence_of :text, :help, :difficulty_id
end
