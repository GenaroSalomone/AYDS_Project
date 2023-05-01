require 'sinatra'
require 'bundler/setup'
require 'sinatra/reloader' if Sinatra::Base.environment == :development

class App < Sinatra::Application
  def initialize(app = nil)
    super()
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
end
# Start the server using rackup
# 1-rackup -p 4567 : Working
# 2-bundle exec rackup -p 4567 : Working
# 3-docker compose up app : Working
