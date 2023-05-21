class ChangeNameAnswers < ActiveRecord::Migration[7.0]
  def change
    remove_column :answers, :texto
    remove_column :answers, :esCorrecta

    add_column :answers, :text, :string
    add_column :answers, :correct, :boolean, default: nil
  end
end
