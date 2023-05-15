class AddTimestampsToAnswers < ActiveRecord::Migration[6.1]
  def change
    #add_column :answers, :created_at, :datetime, null: false
    #add_column :answers, :updated_at, :datetime, null: false
  end
end

# ArgumentError: you can't define an already defined column 'created_at'
# Se estan agregando dos columnas (created_at y update_at) a la tabla answers 
# que ya existen en la tabla.
