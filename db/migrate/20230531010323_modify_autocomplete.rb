class ModifyAutocomplete < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :autocomplets, :questions
    remove_column :autocomplets, :respuestaCorrecta
  end
end
