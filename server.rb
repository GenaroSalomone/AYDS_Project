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

  enable :sessions

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
      erb :protected_page
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

    # Seleccionar 10 preguntas aleatorias para la trivia, teniendo en cuenta si la dificultad
    # es beginner o difficult
    if difficulty_level == "beginner"
      trivia.questions << difficulty.questions.order("RANDOM()").limit(10)
    else
      trivia.questions << difficulty.questions.order("RANDOM()").limit(10)
    end

    trivia.save
    session[:trivia_id] = trivia.id # Guardar el ID de la trivia en la sesión
    redirect '/question/0' # Redirigir a la primera pregunta
  end

  get '/question/:index' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    index = params[:index].to_i
    question = @trivia.questions[index]

    if question.nil? || index >= 10
      redirect '/results' # Redirigir a los resultados si no hay más preguntas
    else
      @question = question
      @answers = Answer.where(question_id: question.id)
      @time_limit_seconds = @trivia.difficulty.level == "beginner" ? 15 : 10
      @question_index = index # Inicializar @question_index con el valor de index
      erb :question, locals: { question: @question, trivia: @trivia, question_index: @question_index, answers: @answers, time_limit_seconds: @time_limit_seconds }
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
        redirect "/question/#{index}" # Redirigir a la misma pregunta si no se seleccionó una respuesta
      else
        # Crear una nueva fila en la tabla QuestionAnswer con los IDs de la pregunta y la respuesta seleccionada
        session[:answered_questions] ||= [] # Inicializar la lista si no existe en la sesión
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

        next_index = index + 1
        redirect "/confirm/#{next_index}" # Redirigir a la página de confirmación intermedia usando GET
      end
    end
  end

  get '/confirm/:index' do
    index = params[:index].to_i
    previous_index = index - 1

    # Verificar si la pregunta anterior ha sido respondida
    if session[:answered_questions].include?(previous_index)
      redirect "/question/#{index}" # Redirigir a la siguiente pregunta si la pregunta anterior ha sido respondida
    else
      redirect '/' # Redirigir a la página inicial de la trivia si se intenta acceder directamente a la página de confirmación intermedia
    end
  end

  get '/results' do
    redirect '/trivia' if @trivia.nil?  # Redirigir si no hay una trivia en sesión

    @user = @trivia.user
    @results = []
    @score = 0
    @idx = 0

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
      @score += 1 if result[:correct]
    end

    erb :results, locals: { results: @results, score: @score }
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
