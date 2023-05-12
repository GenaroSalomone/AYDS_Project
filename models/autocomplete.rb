class Autocomplete < ActiveRecord::Base
   # Herencia
   belongs_to :question

   #Relacion con respuesta
   has_one :answer, foreign_key: 'choice_id'
end
