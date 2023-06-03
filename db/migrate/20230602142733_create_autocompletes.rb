class CreateAutocompletes < ActiveRecord::Migration[7.0]
  def change
    create_table :autocompletes do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.integer :difficulty_id
      t.index :difficulty_id
    end
  end
end
