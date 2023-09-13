class AddIsQuestionTranslatedToQuestions < ActiveRecord::Migration[7.0]
  def change
    add_column :questions, :is_question_translated, :boolean, default: false
  end
end
