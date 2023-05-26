class ModifyQuestionAnswersAndDropQuestionTrivia < ActiveRecord::Migration[7.0]
  def change
    # Eliminar la tabla QuestionTrivia
    drop_table :questions_trivias

    # Agregar la columna trivia_id a la tabla QuestionAnswer
    add_column :question_answers, :trivia_id, :integer
    add_index :question_answers, :trivia_id
  end
end
