class ChangeDefaultAnswersComplete < ActiveRecord::Migration[7.0]
  def up
    change_column_default :answers, :answers_autocomplete, ''
  end

  def down
    change_column_default :answers, :answers_autocomplete, nil
  end
end
