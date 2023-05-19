class RmvFkFromChAns < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :answers, :choices
    add_foreign_key :answers, :choices
  end
end
