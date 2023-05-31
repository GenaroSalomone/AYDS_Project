class DropAutocompletsTable < ActiveRecord::Migration[7.0]
  def change
    drop_table :autocomplets
  end
end
