class Answer < ActiveRecord::Base
  belongs_to :question, polymorphic: true
  has_many :question_answers
  has_many :questions, through: :question_answers
  #indicacion a active record para que reconozca la columna como arreglo
  serialize :answers_autocomplete, JSON

  validates :question_id, presence: true
  validates :text, presence: true
  validates :correct, inclusion: { in: [true, false] }
  validates :text, length: { maximum: 255 }
end
