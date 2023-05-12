class Answer < ActiveRecord::Base
  belongs_to :choice, foreign_key: 'choice_id', optional: true
end
