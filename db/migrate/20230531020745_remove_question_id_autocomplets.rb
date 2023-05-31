class RemoveQuestionIdAutocomplets < ActiveRecord::Migration[7.0]
  def change
    remove_column :autocomplets, :question_id
  end
end
