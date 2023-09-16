class CreateClaims < ActiveRecord::Migration[7.0]
  def change
    create_table :claims do |t|
      t.string :description
      t.references :user, foreign_key: true
      t.timestamps
    end
  end
end
