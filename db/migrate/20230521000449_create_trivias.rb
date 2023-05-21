class CreateTrivias < ActiveRecord::Migration[7.0]
  def change
    create_table :trivias do |t|
      t.references :user, foreign_key: true
      t.references :difficulty, foreign_key: true
      t.timestamps
    end

    #permite asociar múltiples preguntas a una trivia y rastrear las preguntas seleccionadas en cada trivia
    create_table :questions_trivias, id: false do |t|
      t.references :trivia, foreign_key: true
      t.references :question, foreign_key: true
    end
  end
end
