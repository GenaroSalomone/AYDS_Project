require 'sinatra'
require 'bundler/setup'
require 'logger'
require "sinatra/activerecord"
require_relative 'models/user'
require_relative 'models/question'
require_relative 'models/choice'
require_relative 'models/answer'
require 'json'


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
  end

  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  get '/' do 
    erb :index # se ejecuta index
  end
  
  get '/registrarse' do
    erb :signup  # localhost:4567/registrarse
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

  post '/registrarse' do # envia informacion al server (/registrarse)
    # Obtener los datos del formulario
    username = params[:username]
    password = params[:password]
    email = params[:email]

    # Crear un nuevo registro en la base de datos
    user = User.create(username: username, email: email, password: password)

    if user.save
      @message = "¡Registro exitoso!"
      erb :message
    else
      @error_message = "Hubo un error al registrar el usuario: #{user.errors.full_messages.join(', ')}"
      erb :message
    end
  end

  post '/crearChoice' do
    question_id = params[:question_id]
    answer_id1 = params[:answer_id1]
    answer_id2 = params[:answer_id2]
    answer_id3 = params[:answer_id3]
    answer_id4 = params[:answer_id4]

    answers = Answer.where(id: [answer_id1, answer_id2, answer_id3, answer_id4])

    if answers.size == 4
      choice = Choice.new(question_id: question_id)
      choice.answers = answers

      if choice.save
        @message = "¡Registro exitoso!"
        erb :message
      else
        @error_message = "Hubo un error al registrar la elección: #{choice.errors.full_messages.join(', ')}"
        erb :message
      end
    else
      @error_message = "Debes seleccionar exactamente 4 respuestas."
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

  post '/crearAnswer' do
    texto = params[:texto]
    esCorrecta = params[:esCorrecta]

    answer = Answer.create(texto: texto, esCorrecta: esCorrecta)

    if answer.save
      @message = "¡Registro exitoso!"
      erb :message
    else
      @error_message = "Hubo un error al registrar el usuario: #{user.errors.full_messages.join(', ')}"
      erb :message
    end
  end

  get '/welcome' do
    logger.info 'USANDO LOGGER INFO EN WELCOME PATH'
    'Welcome path'
  end

  get '/choice/:id' do
    @choice = Choice.find params[:id]
     @choice_data = {
       id: @choice.id,
       texto: @choice.question.texto,
       answers: @choice.answers.map { |answer| { id: answer.id, texto: answer.texto } }
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


# docker compose exec app bundle exec irb -I. -r server.rb -> WORKING
# sqlite3 db/duo_development.sqlite3
# .schema users --indent
# SELECT * FROM users;
# bundle exec rake db:migrate:status -> VER MIGRACIONES
# seeds.rb en la altura bd. db.seeds para correr

#rake db:create_migration NAME=create_users

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