class AddAnswersAutocompleteToAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :answers, :answers_autocomplete, :text, array: true, default: '{}', null: true
  end
end
