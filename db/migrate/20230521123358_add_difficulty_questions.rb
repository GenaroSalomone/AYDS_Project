class AddDifficultyQuestions < ActiveRecord::Migration[7.0]
  def change
    add_reference :questions, :difficulty, foreign_key: true
  end
end
