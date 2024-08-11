require_relative '../server'

class LoginController < Sinatra::Base

  set :views, File.expand_path('../views', __dir__)

  # method get_registrarse
  # GET endpoint to display the registration page.
  #
  # This route is used to show the web application's registration page when a user visits it.
  #
  # return [ERB] The registration page template.
  get '/registrarse' do
    erb :register
  end

  # method get_login
  # GET endpoint to display the login page.
  #
  # This route is used to show the web application's login page when a user visits it.
  #
  # return [ERB] The login page template.
  get '/login' do
    erb :login
  end

  # method post_registrarse
  # POST endpoint for user registration.
  #
  # This method processes user registration when a user submits the registration form.
  # It validates the submitted data, checks for the availability of the username and email,
  # and creates a new user record in the database if everything is valid.
  #
  # param [String] username The username provided by the user.
  # param [String] password The password provided by the user.
  # param [String] confirm_password The password confirmation provided by the user.
  # param [String] email The email provided by the user.
  #
  # return [ERB] The registration success page or redirects to an error page if there are issues.
  post '/registrarse' do
    username = params[:username]
    email = params[:email]
    password = params[:password]
    confirm_password = params[:confirm_password]

    if username.empty? || email.empty? || password.empty? || confirm_password.empty?
      redirect '/error?code=registration&reason=empty_inputs'
    end

    if password == confirm_password
      if User.exists?(username: username)
        status 302
        redirect '/error?code=registration&reason=username_taken'
      elsif User.exists?(email: email)
        status 302
        redirect '/error?code=registration&reason=email_taken'
      else
        user = User.create(username: username, email: email, password: password)
        if user.save
          status 200
          @message = 'Ir a inicio de sesión.'
          erb :register_success
        else
          status 302
          redirect "/error?code=registration&reason=registration_error&error_message=#{CGI.escape(user.errors.full_messages.join(', '))}"
        end
      end
    else
      status 302
      redirect '/error?code=registration&reason=password_mismatch'
    end
  end

  # method post_login
  # POST endpoint for authenticate and log in the user.
  #
  # This route handles the user authentication process when a user submits the login form.
  # It retrieves the form data, checks the provided username and password against the
  # database records, and logs in the user if the credentials are valid.
  #
  # param [String] :username The username entered in the login form.
  # param [String] :password The password entered in the login form.
  post '/login' do
    username = params[:username]
    password = params[:password]

    if username.empty? || password.empty?
      redirect '/error?code=login&reason=empty_inputs'
    end

    user = User.find_by(username: username)
    if user&.authenticate(password)
      session[:user_id] = user.id
      redirect '/protected_page'
    else
      redirect '/error?code=login&reason=authenticate_failed'
    end
  end

  # method post_google
  # Post endpoint for handling Google Sign-In authentication.
  #
  # This route receives a JSON payload containing an ID token from the Google Sign-In process.
  # It verifies the ID token with Google's authentication service and retrieves user information.
  #
  # return [JSON] A JSON response indicating success or an error message.
  post '/google' do
    request_body = JSON.parse(request.body.read)
    id_token = request_body['id_token']

    begin
      usuario_info = google_verify(id_token)
      usuario = User.find_by(email: usuario_info[:email])
      usuario_por_username = User.find_by(username: usuario_info[:username])

      if !usuario && !usuario_por_username
        user = User.create(username: usuario_info[:username], email: usuario_info[:email], password: ':P')
        session[:user_id] = user.id
      else
        session[:user_id] = usuario.id if usuario
        session[:user_id] = usuario_por_username.id if usuario_por_username
      end

      content_type :json
      {
        correo: usuario_info[:email],
        success: true,
        session: session[:user_id]
      }.to_json
    rescue StandardError => e
      content_type :json
      {
        msg: 'Error en la verificación del token',
        error: e.message
      }.to_json
    end

  end

  # method google_verify
  # Verifies a Google ID token to obtain user information.
  #
  # This method takes a Google ID token as input and verifies its authenticity
  # by making a request to the Google OAuth2 tokeninfo endpoint.
  # If the token is valid and corresponds to the expected client ID, it returns user
  # information including the username, profile picture URL, and email.
  #
  # param token [String] The Google ID token to be verified.
  #
  # return [Hash] A hash containing user information if the token is valid.
  #
  # raise [StandardError] An error is raised if the token cannot be verified
  # or does not match the expected client ID.
  def google_verify(token)
    client_id = ENV['GOOGLE_CLIENT_ID']
    uri = URI.parse("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=#{token}")
    response = Net::HTTP.get_response(uri)
    data = JSON.parse(response.body)
    raise 'Error: El token no se pudo verificar' unless data['aud'] == client_id
    {
      username: data['name'],
      img: data['picture'],
      email: data['email']
    }
  end

end
