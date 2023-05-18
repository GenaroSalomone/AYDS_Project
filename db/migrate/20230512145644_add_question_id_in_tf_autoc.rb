class AddQuestionIdInTfAutoc < ActiveRecord::Migration[7.0]
  def change
    add_reference :autocomplets, :question, null: false, foreign_key: true
    add_reference :true_falses, :question, null:false, foreign_key: true
  end
end
