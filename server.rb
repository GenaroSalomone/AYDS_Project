require_relative 'models_utils'

require 'sinatra/reloader' if Sinatra::Base.environment == :development

class App < Sinatra::Application
  def initialize(app = nil)
    super()
  end

  # General settings
  configure do
    enable :logging
    enable :sessions
    enable :cross_origin

    set :public_folder, File.dirname(__FILE__) + '/public'
    set :session_secret, SecureRandom.hex(64)

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger
  end

  # Development settings
  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  # CORS settings
  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  options "*" do
    response.headers["Allow"] = "GET, PUT, POST, DELETE, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
    response.headers["Access-Control-Allow-Origin"] = "*"
    200
  end

  # Email settings
  email_ayds = ENV['EMAIL_AYDS']
  password_ayds = ENV['PASSWORD_AYDS']
  Mail.defaults do
    delivery_method :smtp, {
      address: 'smtp.gmail.com',
      port: 587,
      user_name: email_ayds,
      password: password_ayds,
      authentication: 'plain',
      enable_starttls_auto: true
    }
  end

  # Verify if exists session trivia
  before do
    if session[:trivia_id]
      @trivia = Trivia.find_by(id: session[:trivia_id])
      redirect '/trivia' if @trivia.nil?
    end
  end

  # @!method get_root
  # GET endpoint to displays the home page.
  #
  # This route is used to show the web application's home page when a user visits it.
  #
  # @return [ERB] The home page template.
  get '/' do
    erb :index
  end

  # @!method get_registrarse
  # GET endpoint to display the registration page.
  #
  # This route is used to show the web application's registration page when a user visits it.
  #
  # @return [ERB] The registration page template.
  get '/registrarse' do
    erb :register
  end

  # @!method get_login
  # GET endpoint to display the login page.
  #
  # This route is used to show the web application's login page when a user visits it.
  #
  # @return [ERB] The login page template.
  get '/login' do
    erb :login
  end

  # @!method post_registrarse
  # POST endpoint for user registration.
  #
  # This method processes user registration when a user submits the registration form.
  # It validates the submitted data, checks for the availability of the username and email,
  # and creates a new user record in the database if everything is valid.
  #
  # @param [String] username The username provided by the user.
  # @param [String] password The password provided by the user.
  # @param [String] confirm_password The password confirmation provided by the user.
  # @param [String] email The email provided by the user.
  #
  # @return [ERB] The registration success page or redirects to an error page if there are issues.
  #
  # @raise [Redirect] If passwords do not match, redirects to '/error?code=registration&reason=password_mismatch'.
  # @raise [Redirect] If username is already in use, redirects to '/error?code=registration&reason=username_taken'.
  # @raise [Redirect] If email is already in use, redirects to '/error?code=registration&reason=email_taken'.
  # @raise [Redirect] If there's an error saving the new user record in the database, redirects to '/error?code=registration&reason=registration_error&error_message=#{CGI.escape(user.errors.full_messages.join(', '))}'.
  #
  # @see User#create
  # @see User#exists?
  # @see User#save
  post '/registrarse' do
    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]
    email = params[:email]

    # Verificar si las contraseñas coinciden
    if password == confirm_password
      # Verificar si el username ya está en uso
      if User.exists?(username: username)
        status 302 # Establece el código de estado HTTP a 302 Found (Redirección)
        redirect "/error?code=registration&reason=username_taken"
      # Verificar si el email ya está en uso
      elsif User.exists?(email: email)
        status 302
        redirect "/error?code=registration&reason=email_taken"
      else
        user = User.create(username: username, email: email, password: password)
        if user.save
          status 200 # Establece el código de estado HTTP a 200
          @message = "Vuelva a logearse por favor, vaya a inicio de sesión."
          erb :register_success
        else
          status 302
          redirect "/error?code=registration&reason=registration_error&error_message=#{CGI.escape(user.errors.full_messages.join(', '))}"
        end
      end
    else
      status 302
      redirect "/error?code=registration&reason=password_mismatch"
    end
  end

  # @!method post_login
  # POST endpoint for authenticate and log in the user.
  #
  # This route handles the user authentication process when a user submits the login form.
  # It retrieves the form data, checks the provided username and password against the
  # database records, and logs in the user if the credentials are valid.
  #
  # @param [String] :username The username entered in the login form.
  # @param [String] :password The password entered in the login form.
  #
  # @return [Redirect] Redirects to '/protected_page' if authentication is successful.
  # @raise [Redirect] Redirects to '/error' with appropriate error code and reason if
  #   authentication fails.
  #
  # @see User#find_by
  # @see User#authenticate
  post '/login' do
    username = params[:username]
    password = params[:password]

    user = User.find_by(username: username)
    if user && user.authenticate(password)
      session[:user_id] = user.id
      redirect '/protected_page'
    else
      redirect "/error?code=login&reason=authenticate_failed"
    end
  end

  # @!method get_protected_page
  # GET endpoint for displaying the protected page if the user is authenticated.
  #
  # This route displays the protected page if the user is authenticated. It checks
  # if there is a user ID stored in the session, retrieves the user's username,
  # and displays the protected page along with the rankings for different
  # difficulty levels.
  #
  # @return [ERB] The protected page with rankings if the user is authenticated.
  # @raise [Redirect] Redirects to '/login' if the user is not authenticated.
  #
  # @see User#find
  # @see Difficulty#find_by
  # @see Ranking#where
  get '/protected_page' do
    if session[:user_id]
      user_id = session[:user_id]
      @username = User.find(user_id).username
      # Usuario autenticado, mostrar página protegida
      # Obtener los rankings
      beginner_difficulty = Difficulty.find_by(level: "beginner")
      difficult_difficulty = Difficulty.find_by(level: "difficult")

      beginner_ranking = Ranking.where(difficulty_id: beginner_difficulty.id).order(score: :desc).limit(10)
      difficult_ranking = Ranking.where(difficulty_id: difficult_difficulty.id).order(score: :desc).limit(10)

      erb :protected_page, locals: { beginner_ranking: beginner_ranking, difficult_ranking: difficult_ranking }
    else
      redirect '/login' # Usuario no autenticado, redirigir a la página de inicio de sesión
    end
  end

  # @!method get_claim
  # GET endpoint for displaying the claim page
  #
  # This route displays the claim page when a user visits '/claim'. It renders the
  # ERB template :claim, which contains the content for the claim page.
  #
  # @return [ERB] The claim page content.
  get '/claim' do
    erb :claim
  end

  # @!method post_claim
  # POST endpoint for handling user claims submission.
  #
  # This route handles the submission of user claims when a POST request is made to '/claim'.
  # It retrieves the user's ID from the session and the description text from the form data.
  # Then the input description is sanitize, this is for some extern attack of malintentioned code.
  # If input was remove then redirect to a error page.
  # If input wasn't remove then creates a new claim record in data base with the provided sanitize
  # description and user ID. If the record was successfully stored then an email was sent to the app
  # managers with the inupt description user.
  #
  # @return [Redirect] Redirects the user to the protected page if the claim is successfully saved,
  # if not redirects to a error page.
  # @see Claim#create
  # @see Claim#save
  post '/claim' do
    user_id = session[:user_id]
    description_text = params[:description]
    cleaned_description = Sanitize.fragment(description_text)
    if cleaned_description.empty?
      status 302
      redirect '/error?code=claim&reason=malicious_block'
    else
      claim = Claim.create(description: cleaned_description, user_id: user_id)
      if claim.save
        user = User.find(user_id)
        username = user.username
        user_email = user.email
        email_one = ENV['EMAIL_ONE']
        email_two = ENV['EMAIL_TWO']
        email_managgers = [email_one, email_two]
        message = "The user #{username} with email #{user_email} says:\n\n#{cleaned_description}"
        Mail.deliver do
          from email_ayds
          to email_managgers
          subject 'New message of AYDS Project App.'
          body message
        end
        redirect '/protected_page'
      else
        status 302
        redirect '/error?code=claim&reason=failed_send_claim'
      end
    end
  end

  # @!method post_trivia
  # POST endpoint for handling trivia creation and initiation.
  #
  # This route handles the creation and initiation of a trivia game when a POST request is made to '/trivia'.
  # It retrieves the current user, the selected difficulty level, and initializes a new trivia game.
  # The number of choice questions, true/false questions, and autocomplete questions are determined
  # based on the selected difficulty level. Random questions are selected from the database for each category,
  # and the questions are shuffled and added to the trivia game.
  #
  # @return [Redirect] Redirects the user to the first question of the trivia game.
  #
  # @see Trivia#questions
  # @see Trivia#translated_questions
  # @see Trivia#save
  # @see session[:trivia_id]
  # @see session[:answered_questions]
  post '/trivia' do
    user = current_user
    difficulty_level = params[:difficulty]
    difficulty = Difficulty.find_by(level: difficulty_level)
    trivia = Trivia.new(user: user, difficulty: difficulty)

    if difficulty_level == "beginner"
      choice_count = rand(3..6)
      true_false_count = rand(3..4)
    else
      choice_count = rand(2..5)
      true_false_count = rand(2..4)
    end

    remaining_count = 10 - choice_count - true_false_count
    autocomplete_count = [remaining_count, 0].max

    choice_questions = difficulty.questions
      .where(type: 'Choice', is_question_translated: false)
      .order("RANDOM()")
      .limit(choice_count)

    true_false_questions = difficulty.questions
      .where(type: 'True_False', is_question_translated: false)
      .order("RANDOM()")
      .limit(true_false_count)

    autocomplete_questions = difficulty.questions
      .where(type: 'Autocomplete', is_question_translated: false)
      .order("RANDOM()")
      .limit(autocomplete_count)

    questions = choice_questions.to_a + true_false_questions.to_a + autocomplete_questions.to_a
    shuffled_questions = questions.shuffle
    trivia.questions.concat(shuffled_questions)
    trivia.translated_questions = []  # Esto eliminará las preguntas traducidas de la trivia actual
    trivia.save
    session[:trivia_id] = trivia.id
    session[:answered_questions] = []

    redirect '/question/0'
  end

  # @!method post_trivia-traduce
  # POST endpoint for handling translated trivia creation and initiation.
  #
  # This route handles the creation and initiation of a translated trivia game when a POST request is made to '/trivia-traduce'.
  # It retrieves the current user, the selected difficulty level, and the selected language code for translation.
  # A new trivia game is initialized, and a specific number of choice and true/false questions are randomly selected
  # based on the selected difficulty level. These questions are then translated to the selected language code using
  # an external translation API.
  #
  # @return [Redirect] Redirects the user to the first translated question of the trivia game.
  #
  # @see Trivia#questions
  # @see Trivia#translated_questions
  # @see session[:trivia_id]
  # @see session[:answered_questions]
  post '/trivia-traduce' do
    user = current_user
    difficulty_level = params[:difficulty]
    selected_language_code = params[:selectedLanguageCode]
    difficulty = Difficulty.find_by(level: difficulty_level)

    trivia = Trivia.new(user: user, difficulty: difficulty, selected_language_code: selected_language_code)

    choice_and_true_false_questions = difficulty.questions
      .where(type: ['Choice', 'True_False'])
      .where(is_question_translated: false)
      .order("RANDOM()")
      .limit(5)
    trivia.questions.concat(choice_and_true_false_questions)

    translated_questions = []
    translated_answers = []

    trivia.questions.each do |question|
      # Hace una solicitud a la API de traducción para traducir el texto al idioma seleccionado
      translated_question_text = translate_to_selected_language(question.text, trivia.selected_language_code)
      # Crea una nueva pregunta traducida y guárdala en el arreglo
      translated_question = case question
        when Choice
          { 'question_type' => 'Choice', 'question' => Choice.create!(text: translated_question_text, difficulty: question.difficulty, is_question_translated: true) }
        when True_False
          { 'question_type' => 'True_False', 'question' => True_False.create!(text: translated_question_text, difficulty: question.difficulty, is_question_translated: true) }
        end
      translated_questions << translated_question

      translated_question_answers = []  # Arreglo para las respuestas traducidas de esta pregunta
      answers = Answer.where(question: question)

      answers.each do |answer|
        translated_answer_text = translate_to_selected_language(answer.text, trivia.selected_language_code) unless answer.question.is_a?(Autocomplete)
        if answer.question.is_a?(Autocomplete)
          translated_answer = Answer.create!(text: translated_answer_text, question_id: translated_question['question']['id'])
        else
          translated_answer = Answer.create!(text: translated_answer_text, question_id: translated_question['question']['id'], correct: answer.correct)
        end
        translated_question_answers << translated_answer
      end

      translated_answers << translated_question_answers
    end
    trivia.translated_questions = translated_questions
    @translated_questions = translated_questions
    @translated_answers = translated_answers

    trivia.save
    session[:trivia_id] = trivia.id
    session[:answered_questions] = []

    redirect '/question-traduce/0'
  end

  # @!method get_question
  # GET endpoint for handling displaying a trivia question.
  #
  # This route is responsible for displaying a trivia question based on the provided index in the URL.
  # If there's no active trivia session, it redirects to the '/trivia' route.
  # It retrieves the question at the specified index and prepares the necessary data for rendering the question view.
  #
  # @param index [Integer] The index of the question to display.
  #
  # @return [ERB] The question view for the specified trivia question.
  #
  # @raise [Redirect] Redirects to '/results' if there are no more questions or if the trivia is complete.
  # @raise [Redirect] Redirects to '/error?code=unanswered' if the user tries to access questions out of order.
  #
  # @see session[:answered_questions]
  # @see Trivia#questions
  # @see Answer.where
  # @see session[:trivia_id]
  get '/question/:index' do
    redirect '/trivia' if @trivia.nil?

    index = params[:index].to_i
    question = @trivia.questions[index]
    previous_index = index.zero? ? 0 : index - 1

    if index.zero? || session[:answered_questions].include?(previous_index)
      if question.nil? || index >= 10
        redirect '/results'
      else
        @question = question
        @answers = Answer.where(question_id: question.id)
        @time_limit_seconds = @trivia.difficulty.level == "beginner" ? 15 : 10
        @question_index = index
        @help = @trivia.difficulty.level == "beginner" ? question.help : nil
        erb :question, locals: { question: @question, trivia: @trivia, question_index: @question_index, answers: @answers, time_limit_seconds: @time_limit_seconds, help: @help}
      end
    else
      redirect "/error?code=unanswered"
    end
  end

  # @!method get_question_traduce
  # GET endpoint for handling displaying a translated trivia question.
  #
  # This route is responsible for displaying a translated trivia question based on the provided index in the URL.
  # If there's no active trivia session, it redirects to the '/trivia' route.
  # It retrieves the translated question at the specified index and prepares the necessary data for rendering the question view.
  #
  # @param index [Integer] The index of the translated question to display.
  #
  # @return [ERB] The translated question view for the specified trivia question.
  #
  # @raise [Redirect] Redirects to '/results-traduce' if there are no more translated questions or if the trivia is complete.
  # @raise [Redirect] Redirects to '/error?code=unanswered' if the user tries to access translated questions out of order.
  #
  # @see session[:answered_questions]
  # @see Trivia#translated_questions
  # @see Answer.where
  # @see session[:trivia_id]
  get '/question-traduce/:index' do
    redirect '/trivia' if @trivia.nil?

    index = params[:index].to_i
    question_hash = @trivia.translated_questions[index]
    previous_index = index.zero? ? 0 : index - 1

    if index.zero? || session[:answered_questions].include?(previous_index)
      if question_hash.nil? || index >= 5
        redirect '/results-traduce'
      else
        @question = question_hash['question']
        @question_type = question_hash['question_type']
        @answers = Answer.where(question_id: @question['id'])
        @time_limit_seconds = @trivia.difficulty.level == "beginner" ? 15 : 10
        @question_index = index
        erb :question_traduce, locals: {
          question: @question,
          question_type: @question_type,
          trivia: @trivia,
          question_index: @question_index,
          answers: @answers,
          time_limit_seconds: @time_limit_seconds,
        }
      end
    else
      redirect "/error?code=unanswered"
    end
  end

  # @!method post_answer
  # POST endpoint for submitting an answer to a trivia question.
  #
  # This route handles the submission of an answer to a trivia question. It checks if the trivia session exists,
  # validates the submitted answer, and records the response time. Depending on the answer type (choice, true/false, or autocomplete),
  # it updates the appropriate tables in the database and redirects to the next question or results page.
  #
  # @param [Integer] index The index of the current question.
  # @param [Integer] selected_answer The ID of the selected answer (for choice and true/false questions).
  # @param [String] autocomplete_input The user's input for autocomplete questions.
  # @param [Integer] response_time The time taken by the user to respond to the question.
  #
  # @return [Redirect] Redirects to the next question or results page.
  #
  # @raise [Redirect] If there is no trivia in session, redirects to '/trivia'.
  # @raise [Redirect] If there are no more questions or if index is greater or equal to 10, redirects to '/results'.
  # @raise [Redirect] If the question has already been answered, redirects to '/error?code=answered'.
  #
  # @see QuestionAnswer
  # @see Answer
  # @see Trivia
  # @see Autocomplete
  post '/answer/:index' do
    redirect '/trivia' if @trivia.nil?

    index = params[:index].to_i
    question = @trivia.questions[index]

    if question.nil? || index >= 10
      redirect '/results'
    else
      selected_answer_id = params[:selected_answer]
      selected_answer = Answer.find_by(id: selected_answer_id, question_id: question.id)
      if selected_answer.nil? && !question.is_a?(Autocomplete)
        session[:answered_questions] << index
        redirect "/question/#{index+1}"
      elsif session[:answered_questions].include?(index)
        redirect '/error?code=answered'
      else
        # Crear una nueva fila en la tabla QuestionAnswer con los IDs de la pregunta y la respuesta seleccionada
        session[:answered_questions] << index # Agregar el índice de la pregunta respondida a la lista
        question_answer = QuestionAnswer.find_or_initialize_by(question_id: question.id, trivia_id: @trivia.id)
        if !selected_answer.nil?
          question_answer.answer_id = selected_answer.id
          question_answer.save
          selected_answer.update(selected: true)
        end
        # Agregar manejo de respuestas para preguntas de autocompletado
        autocomplete_input = params[:autocomplete_input].to_s.strip
        if question.is_a?(Autocomplete)
          answer_autocomplete = Answer.find_by(question_id: question.id)
          answer_autocomplete.update(autocomplete_input: autocomplete_input)
        end

        total_time = @trivia.difficulty == "beginner" ? 15 : 10
        response_time = total_time - params[:response_time].to_i
        question_answer&.update(response_time: response_time)

        next_index = index + 1
        redirect "/question/#{next_index}"
      end
    end
  end

  # @!method post_answer_traduce
  # POST endpoint for submitting an answer to a translated trivia question.
  #
  # This route handles the submission of an answer to a translated trivia question. It checks if the trivia session exists,
  # validates the submitted answer, and records the response time. Depending on the answer type (choice, true/false),
  # it updates the appropriate tables in the database and redirects to the next translated question or results page.
  #
  # @param [Integer] index The index of the current translated question.
  # @param [Integer] selected_answer The ID of the selected answer (for choice and true/false questions).
  # @param [Integer] response_time The time taken by the user to respond to the translated question.
  #
  # @return [Redirect] Redirects to the next translated question or results page.
  #
  # @raise [Redirect] If there is no trivia in session, redirects to '/trivia'.
  # @raise [Redirect] If there are no more questions or if index is greater or equal to 5, redirects to '/results-traduce'.
  # @raise [Redirect] If the question has already been answered, redirects to '/error?code=answered'.
  #
  # @see QuestionAnswer
  # @see Answer
  # @see Trivia
  post '/answer-traduce/:index' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    index = params[:index].to_i
    question_hash = @trivia.translated_questions[index]

    if question_hash.nil? || index >= 5
      redirect '/results-traduce' # Redirigir a los resultados si no hay más preguntas
    else
      selected_answer_id = params[:selected_answer]
      selected_answer = Answer.find_by(id: selected_answer_id, question_id: question_hash['question']['id'])

      if selected_answer.nil?
        session[:answered_questions] << index
        redirect "/question-traduce/#{index+1}"
      elsif session[:answered_questions].include?(index)
        redirect '/error?code=answered'
      else
        # Crear una nueva fila en la tabla QuestionAnswer con los IDs de la pregunta y la respuesta seleccionada
        session[:answered_questions] << index # Agregar el índice de la pregunta respondida a la lista
        question_answer = QuestionAnswer.create!(question_id: question_hash['question']['id'], trivia_id: @trivia.id, answer_id: selected_answer_id)
        #question_answer.save
        selected_answer.update(selected: true)

        total_time = @trivia.difficulty == "beginner" ? 15 : 10
        response_time = total_time - params[:response_time].to_i
        question_answer&.update(response_time: response_time)

        next_index = index + 1
        redirect "/question-traduce/#{next_index}"
      end
    end
  end

  # @!method get_error
  #
  # GET endpoint for displaying an error page.
  #
  # This route is responsible for displaying an error page with a specific error message based on the error code and reason.
  # It handles various error scenarios, such as unanswered questions, answered questions, registration errors, login authentication failure, etc.
  #
  # @param [String] code The error code indicating the type of error.
  # @param [String] reason The reason for the error (optional).
  #
  # @return [ERB] Displays an error page with a custom error message.
  get '/error' do
    error_code = params[:code]
    error_reason = params[:reason]
    @error_message = "Ha ocurrido un error."

    if error_code == "unanswered"
      @error_message = "Se intentó acceder directamente a una pregunta sin haber respondido la pregunta anterior."
    end

    if error_code == "answered"
      @error_message = "La pregunta ya ha sido respondida."
    end

    if error_code == "registration"
      if error_reason == "password_mismatch"
        @error_message = "Las contraseñas no coinciden."
      end

      if error_reason == "registration_error"
        @error_message = "Ha ocurrido un error durante el registro: #{params[:error_message]}"
      end

      if error_reason == "username_taken"
        @error_message = "El nombre de usuario no está disponible."
      end

      if error_reason == "email_taken"
        @error_message = "El email no está disponible."
      end
    end

    if error_code == "login"
      if error_reason == "authenticate_failed"
        @error_message = "El usuario o la contraseña no coinciden. Por favor, vuelva a intentearlo."
      end
    end

    if error_code == "claim"
      if error_reason == "failed_send_claim"
        @error_message = "No se pudo enviar su reclamo o valoración."
      end
      if error_reason == "malicious_block"
        @error_message = "Se detectó código malicioso, el texto no fue enviado."
      end
    end

    erb :error, locals: { error_message: @error_message }
  end

  # @!method get_results
  # GET endpoint for displaying the results of the trivia in the original language.
  #
  # This method displays the results of the trivia in the original language in which it was conducted.
  # It calculates the user's score, checks the answers, and displays whether they were correct or not.
  # If the trivia contains autocomplete questions, it also verifies the correctness of those answers.
  # The method then calculates the user's score based on response times for correct answers.
  # Finally, it handles ranking logic by updating or creating a user's ranking entry for the specific difficulty level.
  #
  # @return [ERB] The results template displaying trivia results.
  #
  # @raise [Redirect] If there is no trivia in session, redirects to '/trivia'.
  #
  # @see QuestionAnswer
  # @see Answer
  # @see Trivia
  get '/results' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    @user = @trivia.user
    @results = []
    @score = 0
    @idx = 0
    response_time_limit = @trivia.difficulty == 'beginner' ? 15 : 10

    @trivia.question_answers.each do |question_answer|
      question = question_answer.question
      selected_answer = Answer.find_by(id: question_answer.answer_id, question_id: question_answer.question_id)
      correct_answer = Answer.find_by(question_id: question_answer.question_id, correct: true)

      result = {
        question: question,
        selected_answer: selected_answer,
        correct_answer: correct_answer,
        correct: false,
        autocomplete_input: nil
      }

      if question.is_a?(Autocomplete)
        answer = Answer.find_by(question_id: question.id)
        result[:correct] = answer.answers_autocomplete.include?(answer.autocomplete_input)
        result[:autocomplete_input] = answer.autocomplete_input
        result[:correct_answer] = answer.answers_autocomplete[0]
      else
        result[:correct] = selected_answer == correct_answer
      end

      @results << result
      # Calcular el puntaje basado en el tiempo de respuesta solo si la respuesta seleccionada es correcta
      if result[:correct] && question_answer.response_time <= response_time_limit
        response_time_score = calculate_response_time_score(question_answer.response_time, response_time_limit)
        @score += response_time_score
      else
        @score += 0
      end

    end

    ###########################Logica para el ranking
    # Obtener el usuario actual
    user = current_user

    # Obtener la dificultad de la trivia
    difficulty = @trivia.difficulty

    # Buscar el ranking existente del usuario para la dificultad actual
    ranking = Ranking.find_by(user_id: user.id, difficulty_id: difficulty.id)

    if ranking.nil? || @score > ranking.score
      # Si no existe un ranking o el nuevo score es mayor al anterior, crear o actualizar el ranking
      ranking = Ranking.find_or_initialize_by(user_id: user.id, difficulty_id: difficulty.id)
      ranking.score = @score
      ranking.difficulty = difficulty
      ranking.save
    end

    erb :results, locals: { results: @results, score: @score }
  end

  # @!method get_results_traduce
  # GET endpoint for displaying the results of the translated trivia.
  #
  # This method displays the results of the translated trivia in which it was conducted.
  # It calculates the user's score, checks the answers, and displays whether they were correct or not.
  # The method then calculates the user's score based on response times for correct answers.
  # Finally, it handles ranking logic by updating or creating a user's ranking entry for the specific difficulty level.
  #
  # @return [ERB] The results template displaying translated trivia results.
  #
  # @raise [Redirect] If there is no trivia in session, redirects to '/trivia'.
  #
  # @see QuestionAnswer
  # @see Answer
  # @see Trivia
  get '/results-traduce' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    @user = @trivia.user
    @results = []
    @score = 0
    @idx = 0
    response_time_limit = @trivia.difficulty == 'beginner' ? 15 : 10

    question_answers = @trivia.question_answers.offset(5)  # 5th position and onwards

    question_answers.each do |question_answer|
      # Fetch the translated question from the session or Trivia object
      translated_question_hash = @trivia.translated_questions.find { |q| q['question']['id'] == question_answer.question_id }
      question = translated_question_hash['question']

      selected_answer = Answer.find_by(id: question_answer.answer_id, question_id: question_answer.question_id)
      correct_answer = Answer.find_by(question_id: question_answer.question_id, correct: true)

      correct = selected_answer == correct_answer

      result = {
        question: question,
        selected_answer: selected_answer,
        correct_answer: correct_answer,
        correct: correct,
      }

      @results << result
      if result[:correct] && question_answer.response_time <= response_time_limit
        response_time_score = calculate_response_time_score(question_answer.response_time, response_time_limit)
        @score += response_time_score
      else
        @score += 0
      end

    end

    user = current_user
    difficulty = @trivia.difficulty
    ranking = Ranking.find_by(user_id: user.id, difficulty_id: difficulty.id)

    if ranking.nil? || @score > ranking.score
      ranking = Ranking.find_or_initialize_by(user_id: user.id, difficulty_id: difficulty.id)
      ranking.score = @score
      ranking.difficulty = difficulty
      ranking.save
    end
    erb :results_traduce, locals: { results: @results, score: @score }
  end

  # @!method post_google
  # Post endpoint for handling Google Sign-In authentication.
  #
  # This route receives a JSON payload containing an ID token from the Google Sign-In process.
  # It verifies the ID token with Google's authentication service and retrieves user information.
  # If the user with the retrieved email or username doesn't exist, a new user is created and logged in.
  # If the user already exists, they are logged in with their existing account.
  #
  # @return [JSON] A JSON response indicating success or an error message.
  post '/google' do
    request_body = JSON.parse(request.body.read)
    id_token = request_body['id_token']

    begin
      usuario_info = google_verify(id_token)
      usuario = User.find_by(email: usuario_info[:email])
      usuario_por_username = User.find_by(username: usuario_info[:username])

      if !usuario && !usuario_por_username
        user = User.create(username: usuario_info[:username], email: usuario_info[:email], password: ':P')
        session[:user_id] = user.id
      else
        session[:user_id] = usuario.id if usuario
        session[:user_id] = usuario_por_username.id if usuario_por_username
      end

      content_type :json
      {
        correo: usuario_info[:email],
        success: true,
        session: session[:user_id],
      }.to_json

    rescue StandardError => e
      content_type :json
      {
        msg: 'Error en la verificación del token',
        error: e.message
      }.to_json
    end
  end

  # @!method get_supported_languages
  # GET endpoint for obtaining supported languages.
  #
  # This method reads data from a local JSON file and returns a list of supported languages.
  # If the data cannot be loaded, it returns an error message.
  #
  # @return [JSON] The list of supported languages.
  #
  # @raise [StandardError] If there is an error reading the file or parsing the JSON, it returns a 500 status code and an error message.
  get '/obtener-lenguajes-soportados' do
    begin
      # Lee los datos desde el archivo JSON local
      languages_data = JSON.parse(File.read(('languages.json')))

      if languages_data.nil?
        status 500
        body 'Error al obtener la lista de lenguajes: No se pudieron cargar los datos.'
      else
        # Define el contenido de la respuesta JSON

        content_type :json
        status 200
        body languages_data['data']['languages'].to_json
      end
    rescue StandardError => e
      status 500
      body 'Error al obtener la lista de lenguajes: ' + e.message
    end
  end

  # @!method current_user
  # Returns the current user based on the session.
  #
  # This method finds and returns the User object associated with the current session.
  # If there is no user_id in the session, it returns nil.
  #
  # @return [User, nil] The User object if there is a user_id in the session, or nil if there isn't.
  #
  # @see User#find
  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  # @!method google_verify
  # Verifies a Google ID token to obtain user information.
  #
  # This method takes a Google ID token as input and verifies its authenticity by making a request to the Google
  # OAuth2 tokeninfo endpoint. If the token is valid and corresponds to the expected client ID, it returns user
  # information including the username, profile picture URL, and email.
  #
  # @param token [String] The Google ID token to be verified.
  #
  # @return [Hash] A hash containing user information if the token is valid.
  #
  # @raise [StandardError] An error is raised if the token cannot be verified or does not match the expected client ID.
  def google_verify(token)
    client_id = ENV['GOOGLE_CLIENT_ID']

    uri = URI.parse("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{token}")
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)

    if data['aud'] == client_id
      {
        username: data['name'],
        img: data['picture'],
        email: data['email']
      }
    else
      raise "Error: El token no se pudo verificar"
    end
  end

  # @!method calculate_response_time_score
  # Calculates the score for response time in a trivia game.
  #
  # This method takes the response time and response time limit as input and calculates the score based on how quickly
  # a question is answered. It assigns a maximum score of 10 points for a correct answer and deducts points based on
  # the time it took to respond. The deduction rate varies depending on the difficulty level.
  #
  # @param response_time [Integer] The time it took to respond to a question in seconds.
  # @param response_time_limit [Integer] The time limit allowed for responding to a question, which varies by difficulty.
  #
  # @return [Integer] The final score based on response time, clamped between 0 and a maximum of 10 points.
  private

  def calculate_response_time_score(response_time, response_time_limit)
    # Asignamos una puntuación máxima de 10 puntos a una respuesta correcta
    max_score = 10

    # Si el nivel es 'beginner', restamos 1 punto por cada 4 segundos que tomó responder la pregunta
    if response_time_limit == 15
      points_to_subtract = [(response_time / 4).ceil, 3].min
    else
      # Si el nivel no es 'beginner', restamos 1 punto por cada 3 segundos que tomó responder la pregunta
      points_to_subtract = [(response_time / 3).ceil, 3].min
    end

    # Calculamos la puntuación final restando los puntos a restar de la puntuación máxima y asegurándonos de que esté dentro del rango 0 a max_score
    final_score = max_score - points_to_subtract
    final_score.clamp(0, max_score)
  end

  # @!method translate_to_selected_language(text, target_language)
  # Translates a given text to the selected language.
  #
  # This method sends a POST request to a translation API with the text to be translated and the target language.
  # It then parses the JSON response and returns the translated text.
  # If there is an error with the request or parsing the response, it outputs an error message and returns nil.
  #
  # @param [String] text The text to be translated.
  # @param [String] target_language The language to translate the text into.
  #
  # @return [String, nil] The translated text if successful, or nil if there was an error.
  #
  # @raise [StandardError] If there is an error with the request or parsing the response, it outputs an error message and returns nil.
  def translate_to_selected_language(text, target_language)
    url = URI("https://text-translator2.p.rapidapi.com/translate")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["content-type"] = 'application/x-www-form-urlencoded'
    request["X-RapidAPI-Key"] = ENV['TEXT_TRANSLATOR_KEY']
    request["X-RapidAPI-Host"] = 'text-translator2.p.rapidapi.com'
    query = URI.encode_www_form(
      source_language: 'es',
      target_language: target_language,
      text: text
    )
    request.body = query
    response = http.request(request)

    if response.code == '200'
      # Parsea la respuesta JSON
      response_data = JSON.parse(response.body)

      if response_data.key?('data') && response_data['data'].key?('translatedText')
        return response_data['data']['translatedText']
      else
        puts "Error: No se encontró 'translatedText' en la respuesta."
        return nil
      end
    else
      puts "Error al traducir: #{response.message}"
      return nil
    end
  end

end
