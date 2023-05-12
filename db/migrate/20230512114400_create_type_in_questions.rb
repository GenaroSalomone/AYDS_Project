class CreateTypeInQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :type, :string
  end
end
