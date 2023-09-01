# spec/app_spec.rb
require 'rack/test'
require_relative '../../server'

#Correr preferentemente con docker compose exec app env RACK_ENV=test bundle exec rspec
ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'

RSpec.describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App
  end

  if ENV['RACK_ENV'] == 'test'
    [User].each(&:destroy_all)
  end

  describe 'POST /registrarse' do
    context 'when the data is valid' do
      it 'redirects the user to a success page' do
        post '/registrarse', {
          username: 'test_user',
          password: 'password',
          confirm_password: 'password',
          email: 'example@example.com'
        }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include('Vuelva a logearse por favor, vaya a inicio de sesión')
      end
    end

    context 'when passwords do not match' do
      it 'redirects the user to a password error page' do
        post '/registrarse', {
          username: 'test_user',
          password: 'password',
          confirm_password: 'incorrect_password',
          email: 'example@example.com'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=registration&reason=password_mismatch')
      end
    end

    context 'when the username is already in use' do
      User.create(username: 'existing_user', password: 'password', email: 'new__user@example.com')
      it 'redirects the user to an error page for duplicate username' do

        post '/registrarse', {
          username: 'existing_user',
          password: 'password',
          confirm_password: 'password',
          email: 'new__user@example.com'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=registration&reason=username_taken')
      end
    end

    context 'when the password confirmation does not match' do
      it 'redirects the user to a password mismatch error page' do
        post '/registrarse', {
          username: 'test_user',
          password: 'password',
          confirm_password: 'different_password',
          email: 'example@example.com'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=registration&reason=password_mismatch')
      end
    end

    context 'when the email is already in use' do
      before(:each) do
        User.create(username: 'existing_user', password: 'password', email: 'example@example.com')
      end

      it 'redirects the user to an email taken error page' do
        post '/registrarse', {
          username: 'test2_user',
          password: 'password',
          confirm_password: 'password',
          email: 'example@example.com'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=registration&reason=email_taken')
      end
    end

  end
end
