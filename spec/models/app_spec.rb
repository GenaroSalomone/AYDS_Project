require 'rack/test'
require 'faker'
require_relative '../../server'

#docker compose exec app env RACK_ENV=test bundle exec rspec
ENV['RACK_ENV'] = 'test'
ENV['APP_ENV'] = 'test'

RSpec.describe 'Sinatra App' do
  include Rack::Test::Methods

  def app
    App
  end

  if ENV['RACK_ENV'] == 'test'
    ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = OFF;')
    [User].each(&:destroy_all)
    ActiveRecord::Base.connection.execute('PRAGMA foreign_keys = ON;')
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


  describe 'POST /login' do
    before(:each) do
      User.create(username: 'test_user3', password: 'password', email: 'email@gmail.com')
    end

    context 'when the login is successful' do
      it 'redirects the user to a protected page with status 200' do
        post '/login', {
          username: 'test_user3',
          password: 'password'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/protected_page')
      end
    end

    context 'when the login fails' do
      it 'redirects the user to an authentication failed error page with status 302' do
        post '/login', {
          username: 'non_existent_user',
          password: 'incorrect_password'
        }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=login&reason=authenticate_failed')
      end
    end
  end


  describe 'GET /protected_page' do
    context 'when the user is authenticated' do
      before(:each) do
        @user = User.create!(username: 'test_user2', password: 'password', email: 'email2@gmail.com')
      end

      it 'displays the protected page' do
        get '/protected_page', {}, { 'rack.session' => { user_id: @user.id } }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include(@user.username)
      end
    end

    context 'when the user is not authenticated' do
      it 'redirects the user to the login page' do
        get '/protected_page'

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/login')
      end
    end
  end


  describe 'GET /question/:index' do
    let!(:user) { User.create!(username: 'unique_username_' + Faker::Lorem.characters(number: 10), password: 'password', email: 'unique_email_' + Faker::Lorem.characters(number: 10) + '@gmail.com') }
    let!(:difficulty) { Difficulty.create!(level: 'beginner') }
    let!(:trivia) { Trivia.create!(user: user, difficulty: difficulty) }
    let!(:question) { Question.create!(text: 'Test question', difficulty: difficulty, type: 'Choice') }

    context 'when the user is authenticated and trivia is in session' do
      before(:each) do
        trivia.questions << question
      end

      it 'displays the question' do
        get '/question/0', {}, { 'rack.session' => { user_id: user.id, trivia_id: trivia.id } }

        expect(last_response.status).to eq(200)
        expect(last_response.body).to include(question.text)
      end
    end

    context 'when the user is not authenticated or trivia is not in session' do
      it 'redirects the user to the trivia page' do
        get '/question/0'
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/trivia')
      end
    end

    context 'when the question index is greater than the number of questions' do
      it 'redirects the user to the results page' do
        (1..10).each do |index|
          question = Question.create!(text: "Question #{index}", difficulty: difficulty, type: 'Choice')
          trivia.questions << question
        end

        get '/question/10', {}, { 'rack.session' => { user_id: user.id, trivia_id: trivia.id, answered_questions: [9] } }

        expect(last_response).to be_redirect
        expect(last_response.location).to include('/results')
      end
    end

    context 'when the user tries to skip a question' do
      it 'redirects the user to the error page' do
        get '/question/1', {}, { 'rack.session' => { user_id: user.id, trivia_id: trivia.id, answered_questions: [] } }

        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error')
      end
    end
  end

  describe 'POST /claim' do
    context 'when description is empty because input user is malicious code' do
      it 'redirects the user to a malicious code error page' do
        post '/claim', {
          description: ''
        }
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=claim&reason=malicious_block')
      end
    end

    context 'when description is not empty but record not was stored' do
      it 'redirect to a error not send message page' do
        post '/claim', {
          description: 'This is a description.',
          user_id: '1'
        }
        expect(last_response.status).to eq(302)
        expect(last_response.location).to include('/error?code=claim&reason=failed_send_claim')
      end
    end
  end

end
