class CreateDifficulties < ActiveRecord::Migration[7.0]
  def change
    create_table :difficulties do |t|
      t.string :level
      t.timestamps null: false
    end
  end
end
