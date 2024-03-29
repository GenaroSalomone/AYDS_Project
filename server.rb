# frozen_string_literal: true

require_relative 'require_utils'
require 'sinatra/reloader' if Sinatra::Base.environment == :development

class App < Sinatra::Application
  include ServerConstants
  # General settings
  configure do
    enable :logging
    enable :sessions
    enable :cross_origin

    set :public_folder, "#{File.dirname(__FILE__)}/public"
    set :session_secret, SecureRandom.hex(64)

    logger = Logger.new($stdout)
    logger.level = Logger::DEBUG if development?
    set :logger, logger

    use LoginController
    use AnswerController
    use ResultsController
    use TriviaController
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

  options '*' do
    response.headers['Allow'] = 'GET, PUT, POST, DELETE, OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token'
    response.headers['Access-Control-Allow-Origin'] = '*'
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

      beginner_difficulty = Difficulty.find_by(level: 'beginner')
      difficult_difficulty = Difficulty.find_by(level: 'difficult')

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
  # If input was remove then redirect to an error page.
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
        send_email(user_id, cleaned_description, email_ayds)
        redirect '/protected_page'
      else
        status 302
        redirect '/error?code=claim&reason=failed_send_claim'
      end
    end
  end

  # @!method get_question
  # GET endpoint for handling displaying a trivia question.
  #
  # @param index [Integer] The index of the question to display.
  #
  # @return [ERB] The question view for the specified trivia question.
  #
  # @raise [Redirect] Redirects to '/results' if there are no more questions or if the trivia is complete.
  # @raise [Redirect] Redirects to '/error?code=unanswered' if the user tries to access questions out of order.
  #
  # @see fetch_question
  get '/question/:index' do
    index = params[:index].to_i
    fetch_question(index)
    erb :question, locals: {
      question: @question,
      trivia: @trivia,
      question_index: @question_index,
      answers: @answers,
      time_limit_seconds: @time_limit_seconds,
      help: @help
    }
  end

  # @!method get_question_traduce
  # GET endpoint for handling displaying a translated trivia question.
  #
  # @param index [Integer] The index of the translated question to display.
  #
  # @return [ERB] The translated question view for the specified trivia question.
  #
  # @raise [Redirect] Redirects to '/results-traduce' if there are no more translated questions or if the trivia is complete.
  # @raise [Redirect] Redirects to '/error?code=unanswered' if the user tries to access translated questions out of order.
  #
  # @see fetch_question
  get '/question-traduce/:index' do
    index = params[:index].to_i
    fetch_question(index, true)
    erb :question_traduce, locals: {
      question: @question,
      trivia: @trivia,
      question_index: @question_index,
      answers: @answers,
      time_limit_seconds: @time_limit_seconds,
      help: @help
    }
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

    # Diccionario o hash que mapea error_code y error_reason a mensajes (Key => Value)
    error_messages = {
      'unanswered' => 'Se intentó acceder directamente a una pregunta sin haber respondido la pregunta anterior.',
      'answered' => 'La pregunta ya ha sido respondida.',
      'registration' => {
        'password_mismatch' => 'Las contraseñas no coinciden.',
        'registration_error' => "Ha ocurrido un error durante el registro: #{params[:error_message]}",
        'username_taken' => 'El nombre de usuario no está disponible.',
        'email_taken' => 'El email no está disponible.'
      },
      'login' => {
        'authenticate_failed' => 'El usuario o la contraseña no coinciden. Por favor, vuelva a intentarlo.'
      },
      'claim' => {
        'failed_send_claim' => 'No se pudo enviar su reclamo o valoración.',
        'malicious_block' => 'Se detectó código malicioso, el texto no fue enviado.'
      }
    }

    error_code = params[:code]
    error_reason = params[:reason]

    @error_message = error_messages[error_code] || 'Ha ocurrido un error.'

    # si error_code es un sub hash del hash error_messages y error_code es una clave en el hash error_messages
    if error_messages[error_code].is_a?(Hash) && error_messages[error_code].key?(error_reason)
      @error_message = error_messages[error_code][error_reason]
    end

    erb :error, locals: { error_message: @error_message }

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
    # Lee los datos desde el archivo JSON local
    languages_data = JSON.parse(File.read('languages.json'))

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
    body "Error al obtener la lista de lenguajes: #{e.message}"
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

  # @!method fetch_question
  # Method for fetching a trivia question or a translated trivia question.
  #
  # @param index [Integer] The index of the question to fetch.
  # @param translated [Boolean] A flag indicating whether to fetch a translated question.
  #
  # @return [void]
  #
  # @raise [Redirect] Redirects to '/trivia' if there's no active trivia session.
  # @raise [Redirect] Redirects to '/results' or '/results-traduce' if there are no more questions or if the trivia is complete.
  # @raise [Redirect] Redirects to '/error?code=unanswered' if the user tries to access questions out of order.
  #
  # @see Trivia#questions
  # @see Trivia#translated_questions
  # @see Answer.where
  def fetch_question(index, translated = false)
    redirect '/trivia' if @trivia.nil?
    previous_index = index.zero? ? 0 : index - 1
    if index.zero? || session[:answered_questions].include?(previous_index)
      question = translated ? @trivia.translated_questions[index] : @trivia.questions[index]
      if question.nil? || (translated && index >= TRANSLATEDS_QUESTIONS) || (!translated && index >= QUESTIONS_SPANISH)
        redirect translated ? '/results-traduce' : '/results'
      else
        @question = translated ? question['question'] : question
        @answers = Answer.where(question_id: @question['id'])
        @time_limit_seconds = @trivia.difficulty.level == 'beginner' ? TIME_BEGINNER : TIME_DIFFICULTY
        @question_index = index
        @help = @trivia.difficulty.level == 'beginner' ? @question['help'] : nil
      end
    else
      redirect '/error?code=unanswered'
    end
  end

  # Send an email to managers app
  def send_email(user_id, description, email_ayds)
    user = User.find(user_id)
    username = user.username
    user_email = user.email
    email_one = ENV['EMAIL_ONE']
    email_two = ENV['EMAIL_TWO']
    email_managgers = [email_one, email_two]
    message = "The user #{username} with email #{user_email} says:\n\n#{description}"
    Mail.deliver do
      from email_ayds
      to email_managgers
      subject 'New message of AYDS Project App.'
      body message
    end
  end

end
