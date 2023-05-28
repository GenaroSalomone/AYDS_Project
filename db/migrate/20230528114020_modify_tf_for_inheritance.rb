class ModifyTfForInheritance < ActiveRecord::Migration[7.0]
  def change
    add_reference :true_falses, :difficulty, foreign_key: true
  end
end
