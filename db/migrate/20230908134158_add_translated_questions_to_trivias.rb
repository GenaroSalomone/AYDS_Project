class AddTranslatedQuestionsToTrivias < ActiveRecord::Migration[7.0]
  def change
    add_column :trivias, :translated_questions, :text
  end
end
