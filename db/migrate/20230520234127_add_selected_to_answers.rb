class AddSelectedToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :selected, :boolean, default: false
  end
end
