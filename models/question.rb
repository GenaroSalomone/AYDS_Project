class Question < ActiveRecord::Base
  has_many :question_answers
  has_many :answers, through: :question_answers
  belongs_to :difficulty

  validates :text, presence: true
  validates :difficulty_id, presence: true

  validate :must_belong_to_subclass

  private

  #una question debe ser necesariamente una subclase de question (no puede haber Questions que no sean subclase de Question)
  def must_belong_to_subclass
    unless self.is_a?(Autocomplete) || self.is_a?(True_False) || self.is_a?(Choice)
      errors.add(:base, 'Question must belong to a subclass')
    end
  end

end


