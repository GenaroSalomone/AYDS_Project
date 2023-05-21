class AddDifficultyToChoices < ActiveRecord::Migration[7.0]
  def change
    add_reference :choices, :difficulty, foreign_key: true
  end
end
