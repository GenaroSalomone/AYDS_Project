# Informe actividad 4 - Rubocop & Refactor

Al iniciar el ciclo de refactorización, lo primero que hicimos fue un analisis del codigo completo, en nuestro caso, un analisis profundo de todo el codigo que teniamos en nuestro archivo server.rb, el cual contenia la logica completa de nuestra aplicacion en conjunto con el manejo de la API.

(Para dar un vistazo a simple vista de lo que hablamos al mencionar server.rb:
[Link_al_viejo_server.rb](https://github.com/GenaroSalomone/AYDS_Project/blob/e322aacf03f47d8f19341cd16a02b6b22230a571/server.rb) )

Al correr rubocop: lo primero que vimos fue:

![Untitled](Informe%20actividad%204%20-%20Rubocop%20&%20Refactor%200eb164678b5b48d097e73e42b81a3ee4/Untitled.png)

Algunos code smells que detectamos analizando la lista de ofensas detectadas por rubocop y haciendo un analisis del codigo:

1. **Código Duplicado**: Hay una cantidad considerable de código duplicado en las diferentes rutas para manejar preguntas y respuestas. 
2. **Métodos Largo**: Los métodos dentro de las rutas son bastante largos y realizan una serie de tareas diferentes que podrían dividirse en métodos más pequeños y enfocados.
3. **Números Mágicos**: Hay números codificados como **`15`**, **`10`** y **`5`** que determinan el comportamiento del programa, como los límites de tiempo para las respuestas o la cantidad de preguntas. 
4. **Complejidad Condicional**: Hay múltiples condiciones anidadas if-else, lo que hace que el código sea difícil de leer y mantener. 

Antes de iniciar el ciclo de refactorizacion, comprobamos que la [test suite](https://github.com/GenaroSalomone/AYDS_Project/tree/e322aacf03f47d8f19341cd16a02b6b22230a571/spec) de la aplicacion se encuentre funcionando, para cuando estemos refactorizando, podamos ir chequeando que los cambios no corrompen la logica de nuestra aplicacion:

![Untitled](Informe%20actividad%204%20-%20Rubocop%20&%20Refactor%200eb164678b5b48d097e73e42b81a3ee4/Untitled%201.png)

Al momento de dar inicio inicio al sprint de refactorizacion, creamos la historia de usuario en Pivotal Tracker para tener un seguimiento de los cambios producidos en el codigo, donde en el siguiente link estaran listados los commits para cada una de las refactorizaciones listadas y explicadas a continuacion → [(Link)](https://www.pivotaltracker.com/story/show/186332802)

***Lista de tareas completadas en nuestro ciclo de refactorizacion:***

- Refactorizacion para endpoints post /answer y post /answer-traduce.  [Link_to_commit](https://github.com/GenaroSalomone/AYDS_Project/commit/85f8f7af2f912c933a70c0a69d557a6669ee9c1c) [Link_to_second_commit](https://github.com/GenaroSalomone/AYDS_Project/commit/0d18f11045f9dd6aeb90d71ec96c79464fa1f110)
    1. **Encapsulamiento y modularización**: Se ha trasladado la lógica de las rutas a un controlador separado (**`AnswerController`**), utilizando la técnica de encapsulamiento para agrupar funcionalidades relacionadas.
    2. **Extracción de métodos**: Se crearon métodos más pequeños y descriptivos (**`handle_answer`**, **`process_answer`**, **`create_or_update_question_answer`**, **`update_response_time`**, **`handle_autocomplete_answer`**, **`handle_unanswered_question`**), aplicando la técnica de extracción de métodos para simplificar y descomponer las rutas.
    3. **Uso de Constantes**: La implementación de constantes (**`TIME_BEGINNER`**, **`TIME_DIFFICULTY`**, **`QUESTIONS_SPANISH`**, **`TRANSLATEDS_QUESTIONS`**) sustituye valores literales, lo que refleja la técnica de reemplazar números mágicos por constantes nombradas. 
    4. **Principio DRY (No te repitas)**: El código reutiliza ahora métodos comunes entre diferentes rutas, lo que refleja el principio DRY y reduce la duplicación de código.
- Refactorizacion para endpoints get /question y get /question-traduce.  [Link_to_commit](https://github.com/GenaroSalomone/AYDS_Project/commit/0ac559662cf73621b6200db177d03adf2c0236a4)
    1. **Extracción de Método**: La lógica común entre las rutas se ha extraído a un nuevo método **`fetch_question`**. Técnica es clave para reducir la duplicación y la complejidad en las rutas.
    2. **Parametrización**: El método **`fetch_question`** acepta un argumento **`translated`**, lo que le permite adaptarse según se necesite para preguntas traducidas o no traducidas.
    3. **Reemplazo de Números Mágicos con Constantes.**
- Refactorizacion para endpoints get /results y get /resuls-traduce.  [Link_to_commit](https://github.com/GenaroSalomone/AYDS_Project/commit/1119a507add60566b948812040dbc578d8912e2d) [Link_to_second_commit](https://github.com/GenaroSalomone/AYDS_Project/commit/3043deb14e424e77eb274b6707138adc3041ca2c)
    1. **Extracción de Método**: El proceso de calcular los resultados y actualizar el ranking se ha extraído a métodos propios (**`calculate_results`**, **`calculate_score`**, **`update_user_ranking`**), lo que simplifica las rutas y hace que la lógica sea reutilizable.
    2. **Encapsulamiento**: Se ha movido la lógica relacionada con el cálculo de los resultados y el ranking a un controlador separado (**`ResultsController`**), lo que ayuda a encapsular la funcionalidad relacionada con los resultados y mantiene el código organizado y enfocado.
    3. **Métodos de Utilidad**: Se han creado métodos de utilidad como **`get_user_and_difficulty`** y **`update_ranking`** que abstraen operaciones comunes y mejoran la legibilidad del código al ocultar los detalles de implementación.
    4. **Parametrización de Métodos**: Los métodos se han parametrizado para aceptar argumentos y trabajar con diferentes contextos, como se ve en **`setup_view_and_calculate_scores`**, lo que los hace flexibles y aplicables en varias situaciones.
    5. **Mejora de cohesión**: Al separar la lógica en métodos individuales, cada uno se ocupa de una sola tarea o conjunto de tareas relacionadas, lo que mejora la cohesión del código.
    6. **Uso de Constantes**: La refactorización continúa el uso de constantes (**`TIME_BEGINNER`**, **`TIME_DIFFICULTY`**) para eliminar los números mágicos, lo que hace que el código sea más fácil de entender y mantener
- Refactorizacion para endpoints post /trivia y post /trivia-traduce.  [Link_to_commit](https://github.com/GenaroSalomone/AYDS_Project/commit/03146703ce5616c153b2430acc70f1eb6d52cb6e)
    1. **Extracción de Método**: Se han extraído bloques de código a métodos separados como **`get_user_difficulty_trivia`** o **`setup_standard_trivia`**
    2. **Descomposición de Método**: Se dividió **`setup_trivia`** en submétodos más simples y enfocados, cada uno manejando aspectos específicos de la configuración de la trivia.
    3. **Separación de Preocupaciones**: Cada método maneja una única responsabilidad, como la creación de preguntas o la finalización de la configuración de trivia.
    4. **Principio DRY (No te Repitas)**: Se eliminó la repetición de código, especialmente en la creación de preguntas traducidas y respuestas.
    5. **Consolidación de logica**: Se centralizaron comportamientos similares, como el manejo de la sesión en **`finalize_trivia_setup`**.
- Creación de un controlador para inicio de sesión y registro de usuario .
    1. **Encapsulamiento**: Se ha trasladado la lógica de determinadas rutas a un controlador separado (**`LoginController`**), utilizando la técnica de encapsulamiento para agrupar funcionalidades relacionadas. Los endpoints post /registrarse, post /login, post /google, get /registrarse, get /login y la función google_verify se trasladaron desde server.rb hacia su controlador especifico, el cuál maneja su lógica.
- Refactorización para endpoint post /claim.
    1. **Extracción de Método**: Se realizo extracción de código en el endpoint /claim, el cuál esta relacionado con la lógica de enviar un email desde el usuario que realizo el reclamo o valoración de la aplicación hacia los manejadores de la app. El método que maneja la lógica es **`send_email`**.
- Refactorización para endpoint post /error.
    1. **Disminución de número de lineas**: El endpoint /error realizaba un manejo repetido de condiciones lógicas (if .. then .. else) para mostrar distintos mensajes de errores. Se encapsulo la lógica en una estructura de datos diccionario, el cuál mapea de **`error_code`** (la Key) a **`error_reason`** (el Value). De esta manera se redujo significativamente el número de lineas en el cuerpo del endpoint.