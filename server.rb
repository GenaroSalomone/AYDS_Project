require 'sinatra'
require 'bundler/setup'
require 'logger'
require "sinatra/activerecord"
require_relative 'models/user'
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
    erb :index
  end

  get '/welcome' do
    logger.info 'USANDO LOGGER INFO EN WELCOME PATH'
    'Welcome path'
  end
end
# Start the server using rackup
# 1-rackup -p 4567 : Working
# 2-bundle exec rackup -p 4567 : Working
# 3-docker compose up app : Working
# Container ayds_project-app-1
# bundle exec rake db:migrate
# bundle exec irb -I. -r server.rb
# user = User.new(name: "John")
# user.save
# User.all
# User.find_by(name: "John")
# puts john.inspect -> imprime el registro en la BD .
# no puedo hacer esto dentro de docker:docker-compose exec app bundle exec irb -I. -r server.rb -> no abre la consola


# docker compose exec app bundle exec irb -I. -r server.rb -> WORKING
# sqlite3 db/duo_development.sqlite3
# .schema users --indent
# bundle exec rake db:migrate:status -> VER MIGRACIONES
