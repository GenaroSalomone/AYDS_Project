require 'sinatra'
require 'bundler/setup'
require 'logger'
require "sinatra/activerecord"
require 'bcrypt'
require 'sinatra/session'
require 'dotenv/load'
require 'securerandom'
require 'enumerize'
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

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 3000
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
    # Crear un nuevo registro en la base de datos
      user = User.create(username: username, email: email, password: password)
      if user.save
        @message = "Vuelva a logearse por favor, vaya a inicio de sesión."
        erb :register_success
      else
        @error_message = "Hubo un error al registrar el usuario: #{user.errors.full_messages.join(', ')}"
        erb :message
      end
    else
      @error_message = "Las contraseñas no coinciden."
      erb :message
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
      @error_message = "Usuario o contraseña incorrectos."
      erb :message
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
    if error_code == "answered"
      @error_message = "Esta pregunta ya ha sido respondida."
    else
      @error_message = "Ha ocurrido un error."
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




  #peticion post para crear una choice
  post '/crearChoice' do
    texto = params[:texto]
    choice = Choice.create(texto: texto)
    if choice.persisted?
      @message = "¡Registro exitoso!"
      erb :message
    else
      @error_message = "Hubo un error al registrar la elección: #{choice.errors.full_messages.join(', ')}"
      erb :message
    end
  end

  #peticion post para crear una answer
  post '/crearAnswer' do
    texto = params[:texto]
    esCorrecta = params[:esCorrecta]
    question_id = params[:question_id]
    answer = Answer.create(texto: texto, esCorrecta: esCorrecta, question_id: question_id)
    if answer.save
      @message = "¡Registro exitoso!"
      erb :message
    else
      @error_message = "Hubo un error al registrar la respuesta: #{answer.errors.full_messages.join(', ')}"
      erb :message
    end
  end

  #peticion post para crear una question
  post '/crearQuestion' do
    texto = params[:texto]
    question = Question.create(texto: texto)
    if question.save
      @message = "¡Registro exitoso!"
      erb :message
    else
      @error_message = "Hubo un error al registrar el usuario: #{user.errors.full_messages.join(', ')}"
      erb :message
    end
  end

  #peticion prueba para obtener informacion desde answer hasta choice
  get '/choice/:id' do
    @choice = Choice.find(params[:id])
    @answers = Answer.where(question_id: @choice.id)
    @choice_data = {
      id: @choice.id,
      texto: @choice.texto
    }
    @answer_data = {
      answers: @answers.map { |answer| { texto: answer.texto, question_id: answer.question_id } }
    }
    erb :choice
  end

  #peticion delete para borrar un user dado un id
  delete '/users/:id' do
    user = User.find(params[:id])
    if user.destroy
      @message = "Borrado exitoso!" # en @message se almacena el msj
      erb :message                  # se invoca message.erb
    else
      @error_message = "Hubo un error al borrar el usuario: #{user.errors.full_messages.join(', ')}"
      erb :message
    end
  end

end

# Start the server using rackup
# 1- rackup -p 4567 : Working
# 2- bundle exec rackup -p 4567 : Working (levanta el server)
# 3-docker compose up app : Working
# Container ayds_project-app-1
# bundle exec rake db:migrate  (Run the migration)
# bundle exec irb -I. -r server.rb
# user = User.new(username: "Cristian")
# user.save
# User.all (muestra los usuarios con sus datos registrados)
# User.find_by(name: "John")
# puts john.inspect -> imprime el registro en la BD .
# no puedo hacer esto dentro de docker:docker-compose exec app bundle exec irb -I. -r server.rb -> no abre la consola


# docker compose up app
# docker compose exec app bundle exec irb -I. -r server.rb -> WORKING
# sqlite3 db/duo_development.sqlite3
# .schema users --indent
# SELECT * FROM users;
# bundle exec rake db:migrate:status -> VER MIGRACIONES
# seeds.rb en la altura bd. db.seeds para correr

#bundle exec rake db:create_migration add_digest

#Asi se veria la herencia entre choice y question, donde mediante esa consulta se veria el texto de la choice.
#SELECT choices.id, questions.texto
#FROM choices
#INNER JOIN questions ON choices.question_id = questions.id
#WHERE choices.id = 2;

#Asi se veria la relacion entre choice y answer, mediante la siguiente consulta:
#SELECT answers.id, answers.texto
#FROM choices
#INNER JOIN answers ON choices.id = answers.choice_id
#WHERE choices.id = 2;

# bundle exec irb -I. -r server.rb
# choice = Choice.first
# question = Question.find 4
# question.choice.answers