
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = OFF;')
if ENV['RACK_ENV'] == 'development'
  # Eliminar los registros existentes antes de crear nuevos
  [Choice, Answer, Question, Difficulty].each(&:destroy_all)
end
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')

# Crea la dificultad "beginner" (Principiante)
beginner_difficulty = Difficulty.create!(level: "beginner")
# Crea la dificultad "difdicult" (Experto)
difficult_difficulty = Difficulty.create!(level: "difficult")

# Crea las preguntas y respuestas
Question.transaction do

  # PREGUNTAS NIVEL PRINCIPIANTE

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
    text: "Ejecutar un programa de manera más eficiente utilizando menos recursos.",
    correct: false
  )
  Answer.create!(
    question: choice_3,
    text: "Crear una copia de seguridad de los datos en un medio externo.",
    correct: false
  )
  Answer.create!(
    question: choice_3,
    text: "Aumentar la velocidad de un componente de hardware más allá de las especificaciones del fabricante.",
    correct: true
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
    text: "Un dispositivo que permite almacenar y recuperar información.",
    correct: false
  )
  Answer.create!(
    question: choice_4,
    text: "Una serie de instrucciones bien escritas para resolver un problema o realizar una tarea.",
    correct: true
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
    text: "Una técnica para verificar la corrección de un programa.",
    correct: false
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
    text: "Una estructura de control que repite un bloque de código varias veces.",
    correct: true
  )

  # Pregunta 7
  choice_7 = Choice.create!(
    text: "¿Qué es un algoritmo de búsqueda?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_7,
    text: "Una forma de organizar y estructurar el código fuente de un programa.",
    correct: false
  )

  Answer.create!(
    question: choice_7,
    text: "Un conjunto de pasos para encontrar un elemento específico dentro de una colección de datos.",
    correct: true
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
    text: "Un enfoque para el desarrollo ágil de software.",
    correct: false
  )

  Answer.create!(
    question: choice_8,
    text: "Un tipo de lenguaje de programación orientado a objetos.",
    correct: false
  )

  Answer.create!(
    question: choice_8,
    text: "El proceso de encontrar y corregir errores en un programa.",
    correct: true
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
    text: "Un lenguaje de programación utilizado para el desarrollo web.",
    correct: false
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
    text: "Un conjunto de herramientas y bibliotecas que facilita el desarrollo de aplicaciones.",
    correct: true
  )

  #Pregunta 11
  choice_11 = Choice.create!(
    text: "¿Cuál de los siguientes lenguajes de programación es funcional?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_11,
    text: "LISP",
    correct: false
  )

  Answer.create!(
    question: choice_11,
    text: "Haskell",
    correct: false
  )

  Answer.create!(
    question: choice_11,
    text: "ML",
    correct: false
  )

  Answer.create!(
    question: choice_11,
    text: "Todos",
    correct: true
  )

  #Pregunta 12
  choice_12 = Choice.create!(
    text: "¿Cómo funcionan los métodos encolar y desencolar de una Cola de Prioridad?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_12,
    text: "Se encola un elemento al final y se desencola un elemento al principio.",
    correct: false
  )

  Answer.create!(
    question: choice_12,
    text: "Se encola un elemento al medio y se desencola el mismo elemento.",
    correct: false
  )

  Answer.create!(
    question: choice_12,
    text: "Se encola un elemento con una cierta prioridad y se desencola un elemento al principio.",
    correct: true
  )

  Answer.create!(
    question: choice_12,
    text: "Ninguna de las opciones anteriores.",
    correct: false
  )

  # PREGUNTAS NIVEL EXPERTO (CHOICE)

  #Pregunta 16
  choice_16 = Choice.create!(
    text: "¿Cómo se llamó la primer computadora construida?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_16,
    text: "SKYNET",
    correct: false
  )

  Answer.create!(
    question: choice_16,
    text: "ENIAC",
    correct: true
  )

  Answer.create!(
    question: choice_16,
    text: "EDVAC",
    correct: false
  )

  Answer.create!(
    question: choice_16,
    text: "IBM 650",
    correct: false
  )

  # Pregunta 18
  choice_18 = Choice.create!(
    text: "¿Cuál de los siguientes lenguajes tiene NOCION DE ESTADO?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_18,
    text: "C++",
    correct: false
  )

  Answer.create!(
    question: choice_18,
    text: "RUBY",
    correct: false
  )

  Answer.create!(
    question: choice_18,
    text: "PYTHON",
    correct: false
  )

  Answer.create!(
    question: choice_18,
    text: "Todas las opciones.",
    correct: true
  )

  # Pregunta 19
  choice_19 = Choice.create!(
    text: "¿Cuántos BITS hacen falta para representar 1 BYTE?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_19,
    text: "4 BITS",
    correct: false
  )

  Answer.create!(
    question: choice_19,
    text: "6 BITS",
    correct: false
  )

  Answer.create!(
    question: choice_19,
    text: "8 BITS",
    correct: true
  )

  Answer.create!(
    question: choice_19,
    text: "Ninguna de las opciones.",
    correct: false
  )

  # Pregunta 21
  choice_21 = Choice.create!(
    text: "¿Cuál es el mejor tiempo de ejecución para un algoritmo?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_21,
    text: "Factorial",
    correct: false
  )

  Answer.create!(
    question: choice_21,
    text: "Lineal",
    correct: false
  )

  Answer.create!(
    question: choice_21,
    text: "Logaritmico",
    correct: false
  )

  Answer.create!(
    question: choice_21,
    text: "Constante",
    correct: true
  )

  # Pregunta 22
  choice_22 = Choice.create!(
    text: "¿Qué hace el algoritmo de Dijkstra?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_22,
    text: "Calcula las distancias más largas entre los nodos.",
    correct: false
  )

  Answer.create!(
    question: choice_22,
    text: "Calcula las distancias más cortas entre los nodos.",
    correct: true
  )

  Answer.create!(
    question: choice_22,
    text: "Calcula las distancias negativas entre los nodos.",
    correct: false
  )

  Answer.create!(
    question: choice_22,
    text: "Todas las opciones.",
    correct: false
  )

  # Pregunta 24
  choice_24 = Choice.create!(
    text: "¿Qué imprime el siguiente programa?
            x := 1;
            Leer(x);
            x := x + 1;
            Escribir(x);",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_24,
    text: "2",
    correct: true
  )

  Answer.create!(
    question: choice_24,
    text: "1",
    correct: false
  )

  Answer.create!(
    question: choice_24,
    text: "x",
    correct: false
  )

  Answer.create!(
    question: choice_24,
    text: "x + 1",
    correct: false
  )

  # Pregunta 25
  choice_25 = Choice.create!(
    text: "¿Cuántos lenguajes de programación se utilizaron para realizar esta página web?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_25,
    text: "Dos",
    correct: false
  )

  Answer.create!(
    question: choice_25,
    text: "Uno",
    correct: false
  )

  Answer.create!(
    question: choice_25,
    text: "Cuatro",
    correct: false
  )

  Answer.create!(
    question: choice_25,
    text: "Tres",
    correct: true
  )

  #Preguntas nivel facil - TRUE FALSE
  true_false1 = True_False.create!(
    text: "La sentencia: int x = 5; tiene un tipado dinámico.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false1,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false1,
    text: "False",
    correct: true
  )

  # Pregunta 14
  true_false2 = True_False.create!(
    text: "Los errores en tiempo de compilación son más sencillos de detectar que los errores en tiempo de ejecución",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false2,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false2,
    text: "False",
    correct: false
  )

  # Pregunta 15
  true_false3 = True_False.create!(
    text: "La libreria stdio.h (standar input output), generalmente se la incluye en programas basados en lenguaje C.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false3,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false3,
    text: "False",
    correct: false
  )

  #Preguntas nivel dificil - TRUE FALSE

   # Pregunta 17
  true_false4 = True_False.create!(
    text: "El orden de evaluación del lenguaje Haskell es Orden Aplicativo.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false4,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false4,
    text: "False",
    correct: true
  )

  # Pregunta 20
  true_false5 = True_False.create!(
    text: "La estructura de datos ARREGLOS, tiene acceso secuencial y directo a sus elementos.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false5,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false5,
    text: "False",
    correct: false
  )

  # Pregunta 23
  true_false6 = True_False.create!(
    text: "La memoria RAM pierde toda su información almacenada cuando se apaga la computadora.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false6,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false6,
    text: "False",
    correct: false
  )

end

