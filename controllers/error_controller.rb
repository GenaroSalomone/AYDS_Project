require_relative '../server'

class ErrorController < Sinatra::Base

  set :views, File.expand_path('../views', __dir__)

  # method get_error
  #
  # GET endpoint for displaying an error page.
  #
  # This route is responsible for displaying an error page with a specific error message
  # based on the error code and reason. It handles various error scenarios
  #
  # param [String] code The error code indicating the type of error.
  # param [String] reason The reason for the error (optional).
  #
  # return [ERB] Displays an error page with a custom error message.
  get '/error' do
    error_messages = {
      'unanswered' => 'Se intentó acceder directamente a una pregunta.',
      'answered' => 'La pregunta ya ha sido respondida.',
      'registration' => {
        'empty_inputs' => 'Usuario, email o contraseña no pueden estar vacíos.',
        'password_mismatch' => 'Las contraseñas no coinciden.',
        'registration_error' => "Ha ocurrido un error durante el registro: #{params[:error_message]}",
        'username_taken' => 'El nombre de usuario no está disponible. Intenta con otro.',
        'email_taken' => 'El email no está disponible. Intenta con otro.'
      },
      'login' => {
        'empty_inputs' => 'Usuario o contraseña no pueden estar vacíos.',
        'authenticate_failed' => 'El usuario o la contraseña no coinciden. Por favor, vuelva a intentarlo.'
      },
      'claim' => {
        'failed_send_claim' => 'No se pudo enviar su mensaje.',
        'malicious_block' => 'Error en el mensaje.'
      }
    }

    error_code = params[:code]
    error_reason = params[:reason]
    @error_message = error_messages[error_code] || 'Ha ocurrido un error.'

    if error_messages[error_code].is_a?(Hash) && error_messages[error_code].key?(error_reason)
      @error_message = error_messages[error_code][error_reason]
    end

    erb :error, locals: { error_message: @error_message }
  end

end
