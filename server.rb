require 'sinatra'
require 'bundler/setup'
require 'logger'
require "sinatra/activerecord"
require 'bcrypt'
require 'sinatra/session'
require 'dotenv/load'
require 'securerandom'
require 'enumerize'
require 'jwt'
require 'net/http'
require 'uri'
require 'json'
require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/choice'
require_relative 'models/answer'
require_relative 'models/difficulty'
require_relative 'models/trivia'
require_relative 'models/question_answer'
require_relative 'models/true_false'
require_relative 'models/autocomplete'
require_relative 'models/ranking'

require 'sinatra/reloader' if Sinatra::Base.environment == :development

class App < Sinatra::Application
  def initialize(app = nil)
    super()
  end

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  configure :production, :development do
    enable :logging

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger

    set :public_folder, File.dirname(__FILE__) + '/public'
  end

  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  enable :sessions
  set :session_secret, SecureRandom.hex(64)

  before do
    # Verificar si hay una trivia en sesión
    if session[:trivia_id]
      @trivia = Trivia.find_by(id: session[:trivia_id])
      redirect '/trivia' if @trivia.nil?  # Redirigir si la trivia no existe
    end
  end

  get '/' do
    erb :index
  end

  get '/registrarse' do
    erb :register
  end

  get '/login' do
    erb :login
  end

  post '/registrarse' do
    # Obtener los datos del formulario
    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]
    email = params[:email]

    # Verificar si las contraseñas coinciden
    if password == confirm_password
      # Verificar si el username ya está en uso
      if User.exists?(username: username)
        redirect "/error?code=registration&reason=username_taken"
      # Verificar si el email ya está en uso
      elsif User.exists?(email: email)
        redirect "/error?code=registration&reason=email_taken"
      else
        # Crear un nuevo registro en la base de datos
        user = User.create(username: username, email: email, password: password)
        if user.save
          @message = "Vuelva a logearse por favor, vaya a inicio de sesión."
          erb :register_success
        else
          redirect "/error?code=registration&reason=registration_error&error_message=#{CGI.escape(user.errors.full_messages.join(', '))}"
        end
      end
    else
      redirect "/error?code=registration&reason=password_mismatch"
    end
  end

  post '/login' do
    # Obtener los datos del formulario
    username = params[:username]
    password = params[:password]

    # Buscar al usuario en la base de datos
    user = User.find_by(username: username)

    # Verificar si el usuario existe y si la contraseña es correcta
    if user && user.authenticate(password)
      # Iniciar sesión al usuario
      session[:user_id] = user.id

      # Redirigir al usuario a una página protegida
      redirect '/protected_page'
    else
      redirect "/error?code=login&reason=authenticate_failed"
    end
  end

  get '/protected_page' do
    if session[:user_id]

      user_id = session[:user_id]
      @username = User.find(user_id).username # en username se almacena el nombre de usuario logeado
      # Usuario autenticado, mostrar página protegida
      # Obtener los rankings
      beginner_difficulty = Difficulty.find_by(level: "beginner")
      difficult_difficulty = Difficulty.find_by(level: "difficult")

      beginner_ranking = Ranking.where(difficulty_id: beginner_difficulty.id).order(score: :desc).limit(10)
      difficult_ranking = Ranking.where(difficulty_id: difficult_difficulty.id).order(score: :desc).limit(10)

      erb :protected_page, locals: { beginner_ranking: beginner_ranking, difficult_ranking: difficult_ranking }
    else
      # Usuario no autenticado, redirigir a la página de inicio de sesión
      redirect '/login'
    end
  end

  post '/trivia' do
    user = current_user
    difficulty_level = params[:difficulty]
    difficulty = Difficulty.find_by(level: difficulty_level)
    trivia = Trivia.new(user: user, difficulty: difficulty)

    if difficulty_level == "beginner"
      choice_count = rand(3..6)
      true_false_count = rand(3..4)
      remaining_count = 10 - choice_count - true_false_count

      autocomplete_count = [remaining_count, 0].max

      choice_questions = difficulty.questions.where(type: 'Choice').order("RANDOM()").limit(choice_count)
      true_false_questions = difficulty.questions.where(type: 'True_False').order("RANDOM()").limit(true_false_count)
      autocomplete_questions = difficulty.questions.where(type: 'Autocomplete').order("RANDOM()").limit(autocomplete_count)

      questions = choice_questions.to_a + true_false_questions.to_a + autocomplete_questions.to_a
      shuffled_questions = questions.shuffle
      trivia.questions.concat(shuffled_questions)
    else
      choice_count = rand(2..5)
      true_false_count = rand(2..4)
      remaining_count = 10 - choice_count - true_false_count

      autocomplete_count = [remaining_count, 0].max

      choice_questions = difficulty.questions.where(type: 'Choice').order("RANDOM()").limit(choice_count)
      true_false_questions = difficulty.questions.where(type: 'True_False').order("RANDOM()").limit(true_false_count)
      autocomplete_questions = difficulty.questions.where(type: 'Autocomplete').order("RANDOM()").limit(autocomplete_count)

      questions = choice_questions.to_a + true_false_questions.to_a + autocomplete_questions.to_a
      shuffled_questions = questions.shuffle
      trivia.questions.concat(shuffled_questions)
    end

    trivia.save
    session[:trivia_id] = trivia.id
    session[:answered_questions] = []

    redirect '/question/0'
  end

  get '/question/:index' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    index = params[:index].to_i #convierte el parametro index en un entero y se guarda en la variable index
    question = @trivia.questions[index] # se obtiene la pregunta con su index y se almacena en question
    previous_index = index.zero? ? 0 : index - 1

    if index.zero? || session[:answered_questions].include?(previous_index)
      if question.nil? || index >= 10
        redirect '/results' # Redirigir a los resultados si no hay más preguntas
      else
        @question = question
        @answers = Answer.where(question_id: question.id)
        @time_limit_seconds = @trivia.difficulty.level == "beginner" ? 15 : 10
        @question_index = index # Inicializar @question_index con el valor de index
        @help = @trivia.difficulty.level == "beginner" ? question.help : nil
        erb :question, locals: { question: @question, trivia: @trivia, question_index: @question_index, answers: @answers, time_limit_seconds: @time_limit_seconds, help: @help}
      end
    else
      redirect "/error?code=unanswered"
    end
  end

  post '/answer/:index' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    index = params[:index].to_i
    question = @trivia.questions[index]

    if question.nil? || index >= 10
      redirect '/results' # Redirigir a los resultados si no hay más preguntas
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
    erb :error, locals: { error_message: @error_message }
  end


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

end

