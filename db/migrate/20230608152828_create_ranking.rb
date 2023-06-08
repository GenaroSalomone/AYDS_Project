class CreateRanking < ActiveRecord::Migration[7.0]
  def change
    create_table :rankings do |t|
      t.references :user, foreign_key: true
      t.integer :score, default: 0
      t.timestamps
    end
  end
end
