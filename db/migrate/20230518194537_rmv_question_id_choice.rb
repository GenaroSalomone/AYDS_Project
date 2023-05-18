class RmvQuestionIdChoice < ActiveRecord::Migration[7.0]
  def change
    remove_column :choices, :question_id
  end
end
