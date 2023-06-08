class AddDifficultyToRanking < ActiveRecord::Migration[7.0]
  def change
    add_reference :rankings, :difficulty, foreign_key: true
  end
end
