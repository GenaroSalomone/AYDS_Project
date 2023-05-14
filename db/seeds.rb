
# Preguntas
question1 = Question.create(texto: "¿Qué es Git y para qué se utiliza en el desarrollo de software?")
question2 = Question.create(texto: "¿Cuál es la diferencia entre lenguaje de programación interpretado y compilado? ")
question3 = Question.create(texto: "¿Qué es el modelo cliente-servidor y cómo se utiliza en aplicaciones web?")
question4 = Question.create(texto: "¿Quién es Alan Turing?")
question5 = Question.create(texto: "¿Cuál de los siguientes lenguajes de programación son ORIENTADOS A OBJETOS?")

# Respuestas correctas de tipo multiple choice
choice1 = Choice.create(texto: "Es un modelo de arquitectura que separa la lógica de presentación y la lógica de negocio.", question: question3)
choice2 = Choice.create(texto: "Es uno de los padres de la computación.", question: question4)
choice3 = Choice.create(texto: "Todos", question: question5)



#Respuestas de tipo multiple choice que no son correctas con ninguna question
choice2_1 =  Choice.create(texto: "Es un filósofo.", question: nil)
choce2_2 = Choice.create(texto: "Es un alemán que invento la máquina enigma.", question: nil)
choice2_3 = Choice.create(texto: "Es un actor.", question: nil)
choice3_1 = Choice.create(texto: "C++", question: nil)
choice3_2 = Choice.create(texto: "Java", question: nil)
choice3_3 = Choice.create(texto: "Java Script", question: nil)


#Ejemplo
# "¿Cuál de los siguientes lenguajes de programación son ORIENTADOS A OBJETOS?"
# 1_ C++ (incorrect)
# 2_ Java (incorrect)
# 3_ Java Script (incorrect)
# 4_ Todos (correct)
# Es decir, la question5 tiene cuatro opciones de respuestas,
# choice3_1, choice3_2, choice3_3 y choice3 (donde choice3 es la correcta)













