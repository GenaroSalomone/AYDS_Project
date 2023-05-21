# choice = Choice.create(text: 'Texto de la pregunta')
# answer = Answer.create(text: 'Texto de la respuesta', correct: true, question: choice)
# answer.question
#
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
    text: "CSS",
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

  Question.update_all(difficulty_id: beginner_difficulty.id)
end


