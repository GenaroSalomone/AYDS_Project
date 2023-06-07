
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = OFF;')
if ENV['RACK_ENV'] == 'development'
  # Eliminar los registros existentes antes de crear nuevos
  [Choice, Answer, Question, Difficulty].each(&:destroy_all)
end
ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')

beginner_difficulty = Difficulty.create!(level: "beginner")
difficult_difficulty = Difficulty.create!(level: "difficult")

=begin

POR CONVENCION:
Preguntas principiantes: 1) Choices -> choice_pri_numero
                         2) True_Falses -> true_false_pri_numero
                         3) Autocompletes -> autocomplete_pri_numero

Preguntas expertas: 1) Choices -> choice_exp_numero
                    2) True_Falses -> true_false_exp_numero
                    3) Autocompletes -> autocomplete_exp_numero
=end

Question.transaction do

  # PREGUNTAS NIVEL PRINCIPIANTE

  # Pregunta 1
  choice_pri_1 = Choice.create!( #ayuda
    text: "¿Qué es un compilador?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_1,
    text: "Un software que traduce el código fuente a lenguaje máquina.",
    correct: true
  )

  Answer.create!(
    question: choice_pri_1,
    text: "Un dispositivo que permite la comunicación entre computadoras.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_1,
    text: "Un componente físico de una computadora.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_1,
    text: "Un programa para diseñar interfaces gráficas de usuario.",
    correct: false
  )

  # Pregunta 2
  choice_pri_2 = Choice.create!(
    text: "¿Cuál de las siguientes opciones NO es un lenguaje de programación?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_2,
    text: "Prolog",
    correct: false
  )
  Answer.create!(
    question: choice_pri_2,
    text: "Java",
    correct: false
  )
  Answer.create!(
    question: choice_pri_2,
    text: "Ruby",
    correct: false
  )
  Answer.create!(
    question: choice_pri_2,
    text: "SQL",
    correct: true
  )

  # Pregunta 3
  choice_pri_3 = Choice.create!( #ayuda
    text: "¿Qué es el overclocking?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_3,
    text: "Ejecutar un programa de manera más eficiente utilizando menos recursos.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_3,
    text: "Crear una copia de seguridad de los datos en un medio externo.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_3,
    text: "Aumentar la velocidad de un componente de hardware más allá de las especificaciones del fabricante.",
    correct: true
  )
  Answer.create!(
    question: choice_pri_3,
    text: "Desarrollar software utilizando métodos ágiles.",
    correct: false
  )

  # Pregunta 4
  choice_pri_4 = Choice.create!(
    text: "¿Qué es un algoritmo?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_4,
    text: "Un dispositivo que permite almacenar y recuperar información.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_4,
    text: "Una serie de instrucciones bien escritas para resolver un problema o realizar una tarea.",
    correct: true
  )
  Answer.create!(
    question: choice_pri_4,
    text: "Un lenguaje de programación utilizado para el desarrollo web.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_4,
    text: "Un estándar para la transferencia de datos en la web.",
    correct: false
  )

  # Pregunta 5
  choice_pri_5 = Choice.create!( #ayuda
    text: "¿Qué es el machine learning?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_5,
    text: "Una rama de la inteligencia artificial que permite a las máquinas aprender y tomar decisiones sin ser programadas explícitamente.",
    correct: true
  )
  Answer.create!(
    question: choice_pri_5,
    text: "Un enfoque de desarrollo de software que utiliza pruebas automatizadas.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_5,
    text: "Una técnica para asegurar la calidad del software mediante la revisión por pares.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_5,
    text: "Un método para el desarrollo rápido de aplicaciones web.",
    correct: false
  )

   # Pregunta 6
   choice_pri_6 = Choice.create!(
    text: "¿Qué es un bucle?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_6,
    text: "Una técnica para verificar la corrección de un programa.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_6,
    text: "Un tipo de dato utilizado para almacenar texto.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_6,
    text: "Un método para organizar y almacenar datos en una estructura jerárquica.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_6,
    text: "Una estructura de control que repite un bloque de código varias veces.",
    correct: true
  )

  # Pregunta 7
  choice_pri_7 = Choice.create!( #ayuda
    text: "¿Qué es un algoritmo de búsqueda?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_7,
    text: "Una forma de organizar y estructurar el código fuente de un programa.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_7,
    text: "Un conjunto de pasos para encontrar un elemento específico dentro de una colección de datos.",
    correct: true
  )

  Answer.create!(
    question: choice_pri_7,
    text: "Un método para optimizar el rendimiento de un programa.",
    correct: false
  )
  Answer.create!(
    question: choice_pri_7,
    text: "Una técnica para garantizar la seguridad de un sistema informático.",
    correct: false
  )

  # Pregunta 8
  choice_pri_8 = Choice.create!( #ayuda
    text: "¿Qué es el debugging?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_8,
    text: "Un enfoque para el desarrollo ágil de software.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_8,
    text: "Un tipo de lenguaje de programación orientado a objetos.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_8,
    text: "El proceso de encontrar y corregir errores en un programa.",
    correct: true
  )

  Answer.create!(
    question: choice_pri_8,
    text: "Un método para realizar pruebas automatizadas en un programa.",
    correct: false
  )

  # Pregunta 9
  choice_pri_9 = Choice.create!(
    text: "¿Qué es un repositorio de código?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_9,
    text: "Un lugar donde se almacena y gestiona el código fuente de un proyecto.",
    correct: true
  )

  Answer.create!(
    question: choice_pri_9,
    text: "Un tipo de estructura de datos utilizada para almacenar y organizar información.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_9,
    text: "Una técnica para proteger un programa contra posibles vulnerabilidades.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_9,
    text: "Un método para optimizar el rendimiento de un programa.",
    correct: false
  )

  # Pregunta 10
  choice_pri_10 = Choice.create!( #ayuda
    text: "¿Qué es un framework?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_10,
    text: "Un lenguaje de programación utilizado para el desarrollo web.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_10,
    text: "Una técnica para el diseño de interfaces de usuario.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_10,
    text: "Un enfoque para la resolución de problemas en la programación.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_10,
    text: "Un conjunto de herramientas y bibliotecas que facilita el desarrollo de aplicaciones.",
    correct: true
  )

  #Pregunta 11
  choice_pri_11 = Choice.create!(
    text: "¿Cuál de los siguientes lenguajes de programación es funcional?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_11,
    text: "LISP",
    correct: false
  )

  Answer.create!(
    question: choice_pri_11,
    text: "Haskell",
    correct: false
  )

  Answer.create!(
    question: choice_pri_11,
    text: "ML",
    correct: false
  )

  Answer.create!(
    question: choice_pri_11,
    text: "Todos",
    correct: true
  )

  #Pregunta 12
  choice_pri_12 = Choice.create!( #ayuda
    text: "¿Cómo funcionan los métodos encolar y desencolar de una Cola de Prioridad?",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: choice_pri_12,
    text: "Se encola un elemento al final y se desencola un elemento al principio.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_12,
    text: "Se encola un elemento al medio y se desencola el mismo elemento.",
    correct: false
  )

  Answer.create!(
    question: choice_pri_12,
    text: "Se encola un elemento con una cierta prioridad y se desencola un elemento al principio.",
    correct: true
  )

  Answer.create!(
    question: choice_pri_12,
    text: "Ninguna de las opciones anteriores.",
    correct: false
  )

  # Preguntas nivel principiante - TRUE FALSE

  # Pregunta 1
  true_false_pri_1 = True_False.create!( #ayuda
    text: "La sentencia: int x = 5; tiene un tipado dinámico.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_1,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false_pri_1,
    text: "False",
    correct: true
  )

  # Pregunta 2
  true_false_pri_2 = True_False.create!( #ayuda
    text: "Los errores en tiempo de compilación son más sencillos de detectar que los errores en tiempo de ejecución",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_2,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_pri_2,
    text: "False",
    correct: false
  )

  # Pregunta 3
  true_false_pri_3 = True_False.create!( #ayuda
    text: "La libreria stdio.h (standar input output), generalmente se la incluye en programas basados en lenguaje C.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_3,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_pri_3,
    text: "False",
    correct: false
  )

  # Pregunta 5
  true_false_pri_4 = True_False.create!(
    text: "Un TERA BYTE es equivalente a mil GIGA BYTES",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_4,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_pri_4,
    text: "False",
    correct: false
  )

  true_false_pri_5 = True_False.create!(
    text: "El sistema operativo Linux se basa en el núcleo Windows.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_5,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false_pri_5,
    text: "False",
    correct: true
  )

  true_false_pri_6 = True_False.create!(
    text: "La inteligencia artificial es capaz de simular el pensamiento humano.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_6,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_pri_6,
    text: "False",
    correct: false
  )

  true_false_pri_7 = True_False.create!(
    text: "El lenguaje de programación Java es un lenguaje interpretado.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_7,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false_pri_7,
    text: "False",
    correct: true
  )

  true_false_pri_8 = True_False.create!(
    text: "El protocolo HTTP significa Hypertext Transfer Protocol.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_8,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_pri_8,
    text: "False",
    correct: false
  )

  true_false_pri_9 = True_False.create!(
    text: "El lenguaje de programación Ruby fue creado en Japón.",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: true_false_pri_9,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_pri_9,
    text: "False",
    correct: false
  )

  # Preguntas AUTOCOMPLETADO, nivel principiante

  # Pregunta 1
  autocomplete_pri_1 = Autocomplete.create!( #ayuda
    text: "El primer ordenador electrónico fue construido en el año _ _ _ _ . ",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_1,
    answers_autocomplete: ["1946", "mil novecientos cuarenta y seis", "Mil novecientos cuarenta y seis"]
  )

  # Pregunta 2
  autocomplete_pri_2 = Autocomplete.create!( #ayuda
    text: "El primer teléfono móvil comercial se lanzó en el año _ _ _ _ . ",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_2,
    answers_autocomplete: ["1983", "mil novecientos ochenta y tres", "Mil novecientos ochenta y tres"]
  )

  # Pregunta 3
  autocomplete_pri_3 = Autocomplete.create!(
    text: "El lenguaje de programación más utilizado en el desarrollo web es _ _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_3,
    answers_autocomplete: ["JavaScript", "javascript", "Javascript"]
  )

  # Pregunta 4
  autocomplete_pri_4 = Autocomplete.create!(
    text: "La arquitectura de computadoras se encarga del diseño y desarrollo de la _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_4,
    answers_autocomplete: ["hardware", "Hardware"]
  )

  # Pregunta 5
  autocomplete_pri_5 = Autocomplete.create!(
    text: "El sistema operativo más utilizado en dispositivos móviles es _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_5,
    answers_autocomplete: ["Android", "android"]
  )

  # Pregunta 6
  autocomplete_pri_6 = Autocomplete.create!(
    text: "El lenguaje de programación creado por Guido van Rossum es _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_6,
    answers_autocomplete: ["Python", "python"]
  )

  # Pregunta 7
  autocomplete_pri_7 = Autocomplete.create!(
    text: "El algoritmo de ordenamiento más conocido y eficiente es _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_7,
    answers_autocomplete: ["Quicksort", "quicksort"]
  )

  # Pregunta 8
  autocomplete_pri_8 = Autocomplete.create!(
    text: "El sistema de gestión de bases de datos más popular es _ _ _ _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_8,
    answers_autocomplete: ["MySQL", "mysql", "MYSQL"]
  )

  # Pregunta 9
  autocomplete_pri_9 = Autocomplete.create!(
    text: "El término utilizado para describir el conjunto de instrucciones ejecutadas por un ordenador es _ _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_9,
    answers_autocomplete: ["programa", "Programa"]
  )

  # Pregunta 10
  autocomplete_pri_10 = Autocomplete.create!(
    text: "El proceso de convertir el código fuente en un programa ejecutable se conoce como _ _ _ _ _ _ _ _ _ _ _ _ .",
    difficulty: beginner_difficulty
  )

  Answer.create!(
    question: autocomplete_pri_10,
    answers_autocomplete: ["compilación", "Compilación", "compilacion", "Compilacion"]
  )

  ####################################################################

  # PREGUNTAS NIVEL EXPERTO (CHOICE)

  # Pregunta 1
  choice_exp_1 = Choice.create!(
    text: "¿Cómo se llamó la primer computadora construida?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_1,
    text: "SKYNET",
    correct: false
  )

  Answer.create!(
    question: choice_exp_1,
    text: "ENIAC",
    correct: true
  )

  Answer.create!(
    question: choice_exp_1,
    text: "EDVAC",
    correct: false
  )

  Answer.create!(
    question: choice_exp_1,
    text: "IBM 650",
    correct: false
  )

  # Pregunta 2
  choice_exp_2 = Choice.create!(
    text: "¿Cuál de los siguientes lenguajes tiene NOCION DE ESTADO?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_2,
    text: "C++",
    correct: false
  )

  Answer.create!(
    question: choice_exp_2,
    text: "RUBY",
    correct: false
  )

  Answer.create!(
    question: choice_exp_2,
    text: "PYTHON",
    correct: false
  )

  Answer.create!(
    question: choice_exp_2,
    text: "Todas las opciones.",
    correct: true
  )

  # Pregunta 3
  choice_exp_3 = Choice.create!(
    text: "¿Cuántos BITS hacen falta para representar 1 BYTE?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_3,
    text: "4 BITS",
    correct: false
  )

  Answer.create!(
    question: choice_exp_3,
    text: "6 BITS",
    correct: false
  )

  Answer.create!(
    question: choice_exp_3,
    text: "8 BITS",
    correct: true
  )

  Answer.create!(
    question: choice_exp_3,
    text: "Ninguna de las opciones.",
    correct: false
  )

  # Pregunta 4
  choice_exp_4 = Choice.create!(
    text: "¿Cuál es el mejor tiempo de ejecución para un algoritmo?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_4,
    text: "Factorial",
    correct: false
  )

  Answer.create!(
    question: choice_exp_4,
    text: "Lineal",
    correct: false
  )

  Answer.create!(
    question: choice_exp_4,
    text: "Logaritmico",
    correct: false
  )

  Answer.create!(
    question: choice_exp_4,
    text: "Constante",
    correct: true
  )

  # Pregunta 5
  choice_exp_5 = Choice.create!(
    text: "¿Qué hace el algoritmo de Dijkstra?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_5,
    text: "Calcula las distancias más largas entre los nodos.",
    correct: false
  )

  Answer.create!(
    question: choice_exp_5,
    text: "Calcula las distancias más cortas entre los nodos.",
    correct: true
  )

  Answer.create!(
    question: choice_exp_5,
    text: "Calcula las distancias negativas entre los nodos.",
    correct: false
  )

  Answer.create!(
    question: choice_exp_5,
    text: "Todas las opciones.",
    correct: false
  )

  # Pregunta 6
  choice_exp_6 = Choice.create!(
    text: "¿Qué imprime el siguiente programa? x := 1; Leer(x); x := x + 1; Escribir(x);",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_6,
    text: "2",
    correct: true
  )

  Answer.create!(
    question: choice_exp_6,
    text: "1",
    correct: false
  )

  Answer.create!(
    question: choice_exp_6,
    text: "x",
    correct: false
  )

  Answer.create!(
    question: choice_exp_6,
    text: "x + 1",
    correct: false
  )

  # Pregunta 7
  choice_exp_7 = Choice.create!(
    text: "¿Cuántos lenguajes de programación se utilizaron para realizar esta página web?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_7,
    text: "Dos",
    correct: false
  )

  Answer.create!(
    question: choice_exp_7,
    text: "Uno",
    correct: false
  )

  Answer.create!(
    question: choice_exp_7,
    text: "Cuatro",
    correct: true
  )

  Answer.create!(
    question: choice_exp_7,
    text: "Tres",
    correct: false
  )

  choice_exp_8 = Choice.create!(
    text: "¿Cuál de los siguientes lenguajes de programación es funcional?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_8,
    text: "Python",
    correct: false
  )

  Answer.create!(
    question: choice_exp_8,
    text: "C++",
    correct: false
  )

  Answer.create!(
    question: choice_exp_8,
    text: "Haskell",
    correct: true
  )

  Answer.create!(
    question: choice_exp_8,
    text: "Java",
    correct: false
  )

  choice_exp_9 = Choice.create!(
    text: "¿Cuál de las siguientes opciones describe mejor la complejidad temporal del algoritmo de ordenamiento QuickSort?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_9,
    text: "O(n)",
    correct: false
  )

  Answer.create!(
    question: choice_exp_9,
    text: "O(n log n)",
    correct: true
  )

  Answer.create!(
    question: choice_exp_9,
    text: "O(n^2)",
    correct: false
  )

  Answer.create!(
    question: choice_exp_9,
    text: "O(log n)",
    correct: false
  )

  choice_exp_10 = Choice.create!(
    text: "¿Cuál de los siguientes sistemas operativos no está basado en el núcleo Linux?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_10,
    text: "Ubuntu",
    correct: false
  )

  Answer.create!(
    question: choice_exp_10,
    text: "Android",
    correct: false
  )

  Answer.create!(
    question: choice_exp_10,
    text: "Windows",
    correct: true
  )

  Answer.create!(
    question: choice_exp_10,
    text: "Fedora",
    correct: false
  )

  choice_exp_11 = Choice.create!(
    text: "¿Cuál de los siguientes conceptos está relacionado con el principio SOLID?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_11,
    text: "Programación estructurada",
    correct: false
  )

  Answer.create!(
    question: choice_exp_11,
    text: "Programación orientada a objetos",
    correct: true
  )

  Answer.create!(
    question: choice_exp_11,
    text: "Programación funcional",
    correct: false
  )

  Answer.create!(
    question: choice_exp_11,
    text: "Programación concurrente",
    correct: false
  )

  choice_exp_12 = Choice.create!(
    text: "¿Cuál de las siguientes opciones describe mejor el patrón de diseño MVC (Model-View-Controller)?",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: choice_exp_12,
    text: "Se utiliza para el desarrollo de aplicaciones de realidad virtual",
    correct: false
  )

  Answer.create!(
    question: choice_exp_12,
    text: "Divide una aplicación en tres componentes principales para separar la lógica de negocios, la presentación y la interacción del usuario",
    correct: true
  )

  Answer.create!(
    question: choice_exp_12,
    text: "Se utiliza para el diseño de bases de datos relacionales",
    correct: false
  )

  Answer.create!(
    question: choice_exp_12,
    text: "Es un algoritmo de búsqueda y ordenamiento eficiente",
    correct: false
  )


  #Preguntas nivel experto - TRUE FALSE

   # Pregunta 1
  true_false_exp_1 = True_False.create!(
    text: "El orden de evaluación del lenguaje Haskell es Orden Aplicativo.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_1,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false_exp_1,
    text: "False",
    correct: true
  )

  # Pregunta 2
  true_false_exp_2 = True_False.create!(
    text: "La estructura de datos ARREGLOS, tiene acceso secuencial y directo a sus elementos.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_2,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_exp_2,
    text: "False",
    correct: false
  )

  # Pregunta 3
  true_false_exp_3 = True_False.create!(
    text: "La memoria RAM pierde toda su información almacenada cuando se apaga la computadora.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_3,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_exp_3,
    text: "False",
    correct: false
  )

  true_false_exp_4 = True_False.create!(
    text: "El lenguaje de programación Python fue lanzado en la década de 1990.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_4,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_exp_4,
    text: "False",
    correct: false
  )

  true_false_exp_5 = True_False.create!(
    text: "El algoritmo de búsqueda binaria requiere que los elementos estén ordenados previamente en la lista.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_5,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_exp_5,
    text: "False",
    correct: false
  )

  true_false_exp_6 = True_False.create!(
    text: "La red social Facebook fue lanzada originalmente para ser utilizada solo por estudiantes universitarios.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_6,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_exp_6,
    text: "False",
    correct: false
  )

  true_false_exp_7 = True_False.create!(
    text: "El lenguaje de programación Java es una variante del lenguaje JavaScript.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_7,
    text: "True",
    correct: false
  )

  Answer.create!(
    question: true_false_exp_7,
    text: "False",
    correct: true
  )

  true_false_exp_8 = True_False.create!(
    text: "El sistema operativo macOS es desarrollado por Apple Inc.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: true_false_exp_8,
    text: "True",
    correct: true
  )

  Answer.create!(
    question: true_false_exp_8,
    text: "False",
    correct: false
  )

  # Preguntas nivel experto - AUTOCOMPLETADO

  # Pregunta 1
  autocomplete_exp_1 = Autocomplete.create!(
    text: "El primer sistema operativo de Microsoft se llamaba _ _ _ _ .",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_1,
    answers_autocomplete: ["MS-DOS", "ms-dos", "Ms-Dos", "ms-Dos"]
  )

  # Pregunta 2
  autocomplete_exp_2 = Autocomplete.create!(
    text: "El concepto de 'Internet de las cosas' se refiere a la interconexión de _ _ _ _ .",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_2,
    answers_autocomplete: ["Dispositivos físicos", "dispositivos fisicos", "Dispositivos Físicos", "dispositivos físicos"]
  )

  autocomplete_exp_3 = Autocomplete.create!(
    text: "El término 'Inteligencia Artificial' fue acuñado por _ _ _ _ en el año 1956.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_3,
    answers_autocomplete: ["John McCarthy", "john mccarthy", "John Mccarthy", "john Mccarthy"]
  )

  autocomplete_exp_4 = Autocomplete.create!(
    text: "El primer lenguaje de programación de alto nivel fue _ _ _ _ _.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_4,
    answers_autocomplete: ["Fortran", "FORTRAN"]
  )

  autocomplete_exp_5 = Autocomplete.create!(
    text: "La arquitectura de computadoras conocida como 'Von Neumann' fue propuesta por _ _ _ _ _ _ _ _ y _ _ _ _ _ _ _ _ _ _ en el año 1945.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_5,
    answers_autocomplete: ["John von Neumann", "john von neumann", "John Von Neumann", "john Von Neumann"]
  )

  autocomplete_exp_6 = Autocomplete.create!(
    text: "El lenguaje de programación orientado a objetos más utilizado actualmente es _ _ _ _ _ _ _ _ _ _.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_6,
    answers_autocomplete: ["Java", "JAVA"]
  )

  autocomplete_exp_7 = Autocomplete.create!(
    text: "El término 'Big Data' se refiere al manejo y análisis de conjuntos de datos extremadamente _ _ _ _ _ _ _ _ _ _.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_7,
    answers_autocomplete: ["grandes", "Grandes"]
  )

  autocomplete_exp_8 = Autocomplete.create!(
    text: "El lenguaje de programación Python fue creado por Guido van _ _ _ _ _ _ _ en el año 1991.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_8,
    answers_autocomplete: ["Rossum", "rossum"]
  )

  autocomplete_exp_9 = Autocomplete.create!(
    text: "La empresa Microsoft fue fundada por Bill _ _ _ _ _ _ _ y Paul Allen en el año 1975.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_9,
    answers_autocomplete: ["Gates", "gates"]
  )

  # Pregunta 3
  autocomplete_exp_10 = Autocomplete.create!(
    text: "El primer teléfono inteligente con pantalla táctil fue el iPhone, lanzado por _ _ _ _ _ _ en el año 2007.",
    difficulty: difficult_difficulty
  )

  Answer.create!(
    question: autocomplete_exp_10,
    answers_autocomplete: ["Apple", "apple"]
  )

end

