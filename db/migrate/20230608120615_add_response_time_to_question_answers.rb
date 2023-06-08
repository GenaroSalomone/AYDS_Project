class AddResponseTimeToQuestionAnswers < ActiveRecord::Migration[7.0]
  def change
    add_column :question_answers, :response_time, :integer, default: 0
  end
end
