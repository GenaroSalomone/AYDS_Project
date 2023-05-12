class Question < ActiveRecord::Base
  has_many :choices, foreign_key: 'question_id'
end

#la asociación has_many :choices en la clase Question permite acceder a todas las instancias de Choice que están asociadas a una instancia
#de Question específica. Esto es posible porque las subclases heredan las asociaciones de la clase base en Rails.
