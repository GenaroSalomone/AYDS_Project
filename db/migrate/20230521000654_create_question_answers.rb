class CreateQuestionAnswers < ActiveRecord::Migration[7.0]
  def change
    # permite asociar múltiples respuestas a una pregunta y rastrear las respuestas seleccionadas por los usuarios en cada pregunta
    create_table :question_answers do |t|
      t.references :question, foreign_key: true
      t.references :answer, foreign_key: true
      t.timestamps
    end
  end
end
