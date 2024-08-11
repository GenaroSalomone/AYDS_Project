require_relative '../server'

class ClaimController < Sinatra::Base

  set :views, File.expand_path('../views', __dir__)

  # method get_claim
  # GET endpoint for displaying the claim page
  #
  # This route displays the claim page when a user want make a claim. It renders the
  # ERB template :claim, which contains the content for the claim page.
  #
  # return [ERB] The claim page content.
  get '/claim' do
    if session[:user_id]
      erb :claim
    else
      redirect '/login'
    end
  end

  # method post_claim
  # POST endpoint for handling user claims submission.
  #
  # This route handles the submission of user claims when a POST request is made to '/claim'.
  # It retrieves the user's ID from the session and the description text from the form data.
  # Then the input description is sanitize.
  # If input was remove then redirect to an error page.
  # If input wasn't remove then creates a new claim record in data base with the provided sanitize
  # description and user ID. If the record was successfully stored then an email was sent to the app
  # managers.
  #
  # return [Redirect] Redirects the user to the protected page if the claim is successfully saved,
  post '/claim' do
    user_id = session[:user_id]
    description_text = params[:description]
    cleaned_description = Sanitize.fragment(description_text)
    if cleaned_description.empty?
      status 302
      redirect '/error?code=claim&reason=malicious_block'
    else
      claim = Claim.create(description: cleaned_description, user_id: user_id)
      if claim.save
        send_email(user_id, cleaned_description, ENV['EMAIL_AYDS'])
        redirect '/protected_page'
      else
        status 302
        redirect '/error?code=claim&reason=failed_send_claim'
      end
    end
  end

  # Send an email to managers app
  def send_email(user_id, description, email_ayds)
    user = User.find(user_id)
    username = user.username
    user_email = user.email
    email_managgers = [ENV['EMAIL_ONE'], ENV['EMAIL_TWO']]
    message = "The user #{username} with email #{user_email} says:\n\n#{description}"
    Mail.deliver do
      from email_ayds
      to email_managgers
      subject 'New message of AYDS App.'
      body message
    end
  end

end
