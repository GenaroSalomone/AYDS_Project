class Answer < ActiveRecord::Base
  belongs_to :choice, foreign_key: 'choice_id'
  belongs_to :autocomplete, foreign_key: 'autocomplete_id'
  belongs_to :true_false, foreign_key: 'true_false_id'
end
