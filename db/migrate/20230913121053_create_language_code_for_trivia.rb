class CreateLanguageCodeForTrivia < ActiveRecord::Migration[7.0]
  def change
    add_column :trivias, :selected_language_code, :string
  end
end
