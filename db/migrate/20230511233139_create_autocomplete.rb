class CreateAutocomplete < ActiveRecord::Migration[7.0]
  def change
    create_table :autocomplets do |t|
      t.string :respuestaCorrecta
      t.timestamps
    end
  end
end
