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
    'Welcome'
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
