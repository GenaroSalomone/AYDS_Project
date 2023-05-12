class CreateChoiceIdToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_reference :answers, :choice, null: true, foreign_key: true
  end
end
