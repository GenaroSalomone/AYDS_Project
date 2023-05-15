class AddColumnToTrueFalses < ActiveRecord::Migration[7.0]
  def change
    add_column :true_falses, :texto, :string
  end
end
