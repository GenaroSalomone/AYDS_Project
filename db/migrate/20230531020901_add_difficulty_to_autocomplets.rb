class AddDifficultyToAutocomplets < ActiveRecord::Migration[7.0]
  def change
    add_reference :autocomplets, :difficulty, foreign_key: true
  end
end
