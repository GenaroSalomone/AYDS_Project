class Ranking < ActiveRecord::Base
  belongs_to :user
  belongs_to :trivia
  belongs_to :difficulty

  validates :user_id, presence: true
  validates :difficulty_id, presence: true
  validates :score, presence: true

  #El score estara necesariamente entre 0 y 100
  validate :score_must_be_between_0_and_100

  private

  def score_must_be_between_0_and_100
    if score.present? && (score < 0 || score > 100)
      errors.add(:score, "must be between 0 and 100")
    end
  end

end
