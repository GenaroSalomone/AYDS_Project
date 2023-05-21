class ChangeNameQuestions < ActiveRecord::Migration[7.0]
  def change
    rename_column :questions, :texto, :text
  end
end
