class RmvChoiceIdFromAnswer < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :answers, :choices
    remove_column :answers, :choice_id
  end
end
