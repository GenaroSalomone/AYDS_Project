class AddColumnHelpToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :help, :text, null: true
  end
end
