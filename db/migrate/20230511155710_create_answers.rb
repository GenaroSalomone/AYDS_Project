class CreateAnswers < ActiveRecord::Migration[7.0]
  def change
    create_table :answers do |t|
      t.string :texto
      t.boolean :esCorrecta
    end
  end
end
