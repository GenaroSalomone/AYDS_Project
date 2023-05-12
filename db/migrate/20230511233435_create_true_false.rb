class CreateTrueFalse < ActiveRecord::Migration[7.0]
  def change
    create_table :true_falses do |t|
      t.timestamps
    end
  end
end
