class ModifyTfQuestionid < ActiveRecord::Migration[7.0]
  def change
    remove_index :true_falses, name: "index_true_falses_on_question_id"
    remove_column :true_falses, :question_id
  end
end
