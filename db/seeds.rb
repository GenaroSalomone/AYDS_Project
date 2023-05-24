
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = OFF;')
if ENV['RACK_ENV'] == 'development'
  # Eliminar los registros existentes antes de crear nuevos
  [Choice, Answer, Question, Difficulty].each(&:destroy_all)
end
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')

# Crea la dificultad "beginner"
beginner_difficulty = Difficulty.create!(level: "beginner")

# Crea las preguntas y respuestas
Question.transaction do
  # Pregunta 1
  choice_1 = Choice.create!(
    text: "¿Qué es un compilador?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_1,
    text: "Un software que traduce el código fuente a lenguaje máquina.",
    correct: true
  )

  Answer.create!(
    question: choice_1,
    text: "Un dispositivo que permite la comunicación entre computadoras.",
    correct: false
  )
  Answer.create!(
    question: choice_1,
    text: "Un componente físico de una computadora.",
    correct: false
  )
  Answer.create!(
    question: choice_1,
    text: "Un programa para diseñar interfaces gráficas de usuario.",
    correct: false
  )

  # Pregunta 2
  choice_2 = Choice.create!(
    text: "¿Cuál de las siguientes opciones NO es un lenguaje de programación?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_2,
    text: "Prolog",
    correct: false
  )
  Answer.create!(
    question: choice_2,
    text: "Java",
    correct: false
  )
  Answer.create!(
    question: choice_2,
    text: "Ruby",
    correct: false
  )
  Answer.create!(
    question: choice_2,
    text: "SQL",
    correct: true
  )

  # Pregunta 3
  choice_3 = Choice.create!(
    text: "¿Qué es el overclocking?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_3,
    text: "Aumentar la velocidad de un componente de hardware más allá de las especificaciones del fabricante.",
    correct: true
  )
  Answer.create!(
    question: choice_3,
    text: "Crear una copia de seguridad de los datos en un medio externo.",
    correct: false
  )
  Answer.create!(
    question: choice_3,
    text: "Ejecutar un programa de manera más eficiente utilizando menos recursos.",
    correct: false
  )
  Answer.create!(
    question: choice_3,
    text: "Desarrollar software utilizando métodos ágiles.",
    correct: false
  )

  # Pregunta 4
  choice_4 = Choice.create!(
    text: "¿Qué es un algoritmo?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_4,
    text: "Una serie de instrucciones para resolver un problema o realizar una tarea.",
    correct: true
  )
  Answer.create!(
    question: choice_4,
    text: "Un dispositivo que permite almacenar y recuperar información.",
    correct: false
  )
  Answer.create!(
    question: choice_4,
    text: "Un lenguaje de programación utilizado para el desarrollo web.",
    correct: false
  )
  Answer.create!(
    question: choice_4,
    text: "Un estándar para la transferencia de datos en la web.",
    correct: false
  )

  # Pregunta 5
  choice_5 = Choice.create!(
    text: "¿Qué es el machine learning?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_5,
    text: "Una rama de la inteligencia artificial que permite a las máquinas aprender y tomar decisiones sin ser programadas explícitamente.",
    correct: true
  )
  Answer.create!(
    question: choice_5,
    text: "Un enfoque de desarrollo de software que utiliza pruebas automatizadas.",
    correct: false
  )
  Answer.create!(
    question: choice_5,
    text: "Una técnica para asegurar la calidad del software mediante la revisión por pares.",
    correct: false
  )
  Answer.create!(
    question: choice_5,
    text: "Un método para el desarrollo rápido de aplicaciones web.",
    correct: false
  )

   # Pregunta 6
   choice_6 = Choice.create!(
    text: "¿Qué es un bucle?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_6,
    text: "Una estructura de control que repite un bloque de código varias veces.",
    correct: true
  )

  Answer.create!(
    question: choice_6,
    text: "Un tipo de dato utilizado para almacenar texto.",
    correct: false
  )
  Answer.create!(
    question: choice_6,
    text: "Un método para organizar y almacenar datos en una estructura jerárquica.",
    correct: false
  )
  Answer.create!(
    question: choice_6,
    text: "Una técnica para verificar la corrección de un programa.",
    correct: false
  )

  # Pregunta 7
  choice_7 = Choice.create!(
    text: "¿Qué es un algoritmo de búsqueda?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_7,
    text: "Un conjunto de pasos para encontrar un elemento específico dentro de una colección de datos.",
    correct: true
  )

  Answer.create!(
    question: choice_7,
    text: "Una forma de organizar y estructurar el código fuente de un programa.",
    correct: false
  )
  Answer.create!(
    question: choice_7,
    text: "Un método para optimizar el rendimiento de un programa.",
    correct: false
  )
  Answer.create!(
    question: choice_7,
    text: "Una técnica para garantizar la seguridad de un sistema informático.",
    correct: false
  )

  # Pregunta 8
  choice_8 = Choice.create!(
    text: "¿Qué es el debugging?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_8,
    text: "El proceso de encontrar y corregir errores en un programa.",
    correct: true
  )

  Answer.create!(
    question: choice_8,
    text: "Un tipo de lenguaje de programación orientado a objetos.",
    correct: false
  )
  Answer.create!(
    question: choice_8,
    text: "Un enfoque para el desarrollo ágil de software.",
    correct: false
  )
  Answer.create!(
    question: choice_8,
    text: "Un método para realizar pruebas automatizadas en un programa.",
    correct: false
  )

  # Pregunta 9
  choice_9 = Choice.create!(
    text: "¿Qué es un repositorio de código?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_9,
    text: "Un lugar donde se almacena y gestiona el código fuente de un proyecto.",
    correct: true
  )

  Answer.create!(
    question: choice_9,
    text: "Un tipo de estructura de datos utilizada para almacenar y organizar información.",
    correct: false
  )
  Answer.create!(
    question: choice_9,
    text: "Una técnica para proteger un programa contra posibles vulnerabilidades.",
    correct: false
  )
  Answer.create!(
    question: choice_9,
    text: "Un método para optimizar el rendimiento de un programa.",
    correct: false
  )

  # Pregunta 10
  choice_10 = Choice.create!(
    text: "¿Qué es un framework?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_10,
    text: "Un conjunto de herramientas y bibliotecas que facilita el desarrollo de aplicaciones.",
    correct: true
  )

  Answer.create!(
    question: choice_10,
    text: "Una técnica para el diseño de interfaces de usuario.",
    correct: false
  )
  Answer.create!(
    question: choice_10,
    text: "Un enfoque para la resolución de problemas en la programación.",
    correct: false
  )
  Answer.create!(
    question: choice_10,
    text: "Un lenguaje de programación utilizado para el desarrollo web.",
    correct: false
  )

end

