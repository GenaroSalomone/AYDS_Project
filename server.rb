require 'sinatra'
require 'bundler/setup'
require 'logger'
require "sinatra/activerecord"
require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/choice'
require_relative 'models/answer'
require 'json'
require 'bcrypt'
require 'sinatra/session'
require 'dotenv/load'
require 'securerandom'

require 'sinatra/reloader' if Sinatra::Base.environment == :development

class App < Sinatra::Application
  def initialize(app = nil)
    super()
  end

  configure :production, :development do
    enable :logging

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG if development?
    set :logger, logger

    set :public_folder, File.dirname(__FILE__) + '/public' # Agregar esta línea aquí
  end

  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  enable :sessions
  set :session_secret, SecureRandom.hex(64)

  get '/' do
    erb :index # se ejecuta index
  end

  get '/registrarse' do
    erb :register  # localhost:4567/registrarse
  end

  get '/login' do
    erb :login
  end

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
        @message = "¡Comience a realizar la trivia!"
        erb :register_success
      else
        @error_message = "Hubo un error al registrar el usuario: #{user.errors.full_messages.join(', ')}"
        erb :message
      end
    else
      @error_message = "Las contraseñas no coinciden"
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
      @error_message = "Nombre de usuario o contraseña incorrectos"
      erb :message
    end
  end

  get '/protected_page' do
    if session[:user_id]
      # Usuario autenticado, mostrar página protegida
      erb :protected_page
    else
      # Usuario no autenticado, redirigir a la página de inicio de sesión
      redirect '/login'
    end
  end

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
