require 'sinatra/base'

class App < Sinatra::Application
  def initialize(app = nil)
    super()
  end

  get '/' do
    'Welcome'
  end
end

# Start the server using rackup
# rackup -p 4567 : Working
