class Question < ActiveRecord::Base
  # Relación de herencia
  has_one :true_false #, optional: true
  has_one :autocompletado #, optional: true
  has_one :choice #, optional: true
  #Sin el opcional, no estaria diciendo que una question es las 3 a la vez, o el opcional esta implicito
end


