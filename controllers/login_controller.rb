require_relative '../server'

class LoginController < Sinatra::Base

  set :views, File.expand_path('../views', __dir__)

  # @!method get_registrarse
  # GET endpoint to display the registration page.
  #
  # This route is used to show the web application's registration page when a user visits it.
  #
  # @return [ERB] The registration page template.
  get '/registrarse' do
    erb :register
  end

  # @!method get_login
  # GET endpoint to display the login page.
  #
  # This route is used to show the web application's login page when a user visits it.
  #
  # @return [ERB] The login page template.
  get '/login' do
    erb :login
  end

  # @!method post_registrarse
  # POST endpoint for user registration.
  #
  # This method processes user registration when a user submits the registration form.
  # It validates the submitted data, checks for the availability of the username and email,
  # and creates a new user record in the database if everything is valid.
  #
  # @param [String] username The username provided by the user.
  # @param [String] password The password provided by the user.
  # @param [String] confirm_password The password confirmation provided by the user.
  # @param [String] email The email provided by the user.
  #
  # @return [ERB] The registration success page or redirects to an error page if there are issues.
  #
  # @raise [Redirect] If passwords do not match, redirects to '/error?code=registration&reason=password_mismatch'.
  # @raise [Redirect] If username is already in use, redirects to '/error?code=registration&reason=username_taken'.
  # @raise [Redirect] If email is already in use, redirects to '/error?code=registration&reason=email_taken'.
  # @raise [Redirect] If there's an error saving the new user record in the database, redirects to '/error?code=registration&reason=registration_error
  #
  # @see User#create
  # @see User#exists?
  # @see User#save
  post '/registrarse' do
    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]
    email = params[:email]

    # Verificar si las contraseñas coinciden
    if password == confirm_password
      # Verificar si el username ya está en uso
      if User.exists?(username: username)
        status 302 # Establece el código de estado HTTP a 302 Found (Redirección)
        redirect '/error?code=registration&reason=username_taken'
      # Verificar si el email ya está en uso
      elsif User.exists?(email: email)
        status 302
        redirect '/error?code=registration&reason=email_taken'
      else
        user = User.create(username: username, email: email, password: password)
        if user.save
          status 200 # Establece el código de estado HTTP a 200
          @message = 'Vuelva a logearse por favor, vaya a inicio de sesión.'
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


  # @!method post_login
  # POST endpoint for authenticate and log in the user.
  #
  # This route handles the user authentication process when a user submits the login form.
  # It retrieves the form data, checks the provided username and password against the
  # database records, and logs in the user if the credentials are valid.
  #
  # @param [String] :username The username entered in the login form.
  # @param [String] :password The password entered in the login form.
  #
  # @return [Redirect] Redirects to '/protected_page' if authentication is successful.
  # @raise [Redirect] Redirects to '/error' with appropriate error code and reason if
  #   authentication fails.
  #
  # @see User#find_by
  # @see User#authenticate
  post '/login' do
    username = params[:username]
    password = params[:password]

    user = User.find_by(username: username)
    if user&.authenticate(password)
      session[:user_id] = user.id
      redirect '/protected_page'
    else
      redirect '/error?code=login&reason=authenticate_failed'
    end
  end

end
