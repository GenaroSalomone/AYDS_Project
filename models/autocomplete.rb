class Autocomplete < Question
  self.table_name = 'autocomplets'
  has_many :question_answers
  has_many :answers, as: :question, through: :question_answers
  belongs_to :difficulty
end
