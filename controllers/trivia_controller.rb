require_relative '../server'
require_relative '../constants'

class TriviaController < Sinatra::Base
  include ServerConstants

  # @!method setup_trivia
  # Sets up a trivia game with standard or translated questions based on the parameters.
  #
  # This method orchestrates the creation of a trivia game by calling methods to initialize
  # the trivia object, setting up either standard or translated trivia questions, and then
  # finalizing the trivia setup by saving it and setting up the session.
  #
  # @param params [Hash] The request parameters containing the difficulty level and, if applicable, the selected language code for translations.
  # @param session [Hash] The current user's session for retrieving user data and storing the trivia session.
  # @param translate [Boolean] Flag to determine if the trivia should be set up with translated questions.
  # @return [void]
  # @see get_user_difficulty_trivia
  # @see setup_standard_trivia
  # @see setup_translated_trivia
  # @see finalize_trivia_setup
  def setup_trivia(params, session, translate:)
    user, difficulty, trivia = get_user_difficulty_trivia(params, session)
    if translate
      setup_translated_trivia(trivia, difficulty, params[:selectedLanguageCode])
    else
      setup_standard_trivia(trivia, difficulty)
    end
    finalize_trivia_setup(trivia, session)
  end

  # @!method get_user_difficulty_trivia
  # Retrieves the current user, the selected difficulty, and initializes a new trivia object.
  #
  # This method is responsible for finding the current user from the session, fetching the difficulty level from the request parameters,
  # and creating a new trivia instance with those parameters.
  #
  # @param params [Hash] The request parameters containing the difficulty level.
  # @param session [Hash] The current user's session for retrieving user data.
  # @return [Array] An array containing the user, the difficulty object, and the newly initialized trivia object.
  # @see User#find
  # @see Difficulty#find_by
  # @see Trivia#new
  def get_user_difficulty_trivia(params, session)
    user = User.find(session[:user_id]) if session[:user_id]
    difficulty_level = params[:difficulty]
    difficulty = Difficulty.find_by(level: difficulty_level)
    trivia = Trivia.new(user: user, difficulty: difficulty)
    [user, difficulty, trivia]
  end

  # @!method setup_standard_trivia
  # Sets up standard trivia questions for the game.
  #
  # This method adds a set number of random choice, true/false, and autocomplete questions to the trivia
  # based on the difficulty level provided.
  #
  # @param trivia [Trivia] The trivia object to which the questions will be added.
  # @param difficulty [Difficulty] The difficulty object that determines the number and type of questions to add.
  # @return [void]
  # @see get_questions_count
  # @see get_questions
  def setup_standard_trivia(trivia, difficulty)
    choice_count, true_false_count, autocomplete_count = get_questions_count(difficulty.level)
    questions = get_questions(choice_count, true_false_count, autocomplete_count, difficulty)
    trivia.questions.concat(questions)
  end

  # @!method setup_translated_trivia
  # Sets up translated trivia questions for the game.
  #
  # This method fetches a set of standard questions and then creates translated versions of those questions and answers
  # in the selected language. It then adds these translated questions to the trivia.
  #
  # @param trivia [Trivia] The trivia object to which the translated questions will be added.
  # @param difficulty [Difficulty] The difficulty object that determines which questions to translate.
  # @param selected_language_code [String] The language code representing the target language for translation.
  # @return [void]
  # @see get_translated_questions
  # @see create_translated_questions_and_answers
  def setup_translated_trivia(trivia, difficulty, selected_language_code)
    trivia.selected_language_code = selected_language_code
    choice_and_true_false_questions = get_translated_questions(difficulty)
    trivia.questions.concat(choice_and_true_false_questions)
    translated_questions, translated_answers = create_translated_questions_and_answers(trivia, trivia.questions)
    trivia.translated_questions = translated_questions
  end

  # @!method finalize_trivia_setup
  # Finalizes the trivia setup by saving the trivia instance and initializing session variables.
  #
  # This method is called after setting up the trivia questions. It saves the trivia instance to the database
  # and initializes the session variables to track the trivia id and the questions answered by the user.
  #
  # @param trivia [Trivia] The trivia instance that needs to be finalized and saved.
  # @param session [Hash] The session hash where the trivia id and answered questions are stored.
  # @return [void]
  def finalize_trivia_setup(trivia, session)
    trivia.save
    session[:trivia_id] = trivia.id
    session[:answered_questions] = []
  end

  # @!method get_questions_count
  # Determines the count of different types of questions based on the difficulty level.
  #
  # This method calculates how many choice, true/false, and autocomplete questions should be included in the trivia
  # based on the difficulty level provided. It ensures the total count adds up to 10 questions.
  #
  # @param difficulty_level [String] The level of difficulty selected for the trivia.
  # @return [Array<Integer>] An array containing the count of choice, true/false, and autocomplete questions.
  def get_questions_count(difficulty_level)
    if difficulty_level == 'beginner'
      choice_count = rand(3..6)
      true_false_count = rand(3..4)
    else
      choice_count = rand(2..5)
      true_false_count = rand(2..4)
    end
    remaining_count = 10 - choice_count - true_false_count
    autocomplete_count = [remaining_count, 0].max
    [choice_count, true_false_count, autocomplete_count]
  end

  # @!method get_questions
  # Retrieves a shuffled array of questions for the trivia.
  #
  # This method gathers a specified number of choice, true/false, and autocomplete questions based on counts provided.
  # It then shuffles the collection of questions before returning them.
  #
  # @param choice_count [Integer] The number of choice questions to retrieve.
  # @param true_false_count [Integer] The number of true/false questions to retrieve.
  # @param autocomplete_count [Integer] The number of autocomplete questions to retrieve.
  # @param difficulty [Difficulty] The difficulty object associated with the questions.
  # @return [Array<Question>] An array of questions, shuffled and ready to be added to the trivia.
  def get_questions(choice_count, true_false_count, autocomplete_count, difficulty)
    choice_questions = random_questions(choice_count, 'Choice', difficulty)
    true_false_questions = random_questions(true_false_count, 'True_False', difficulty)
    autocomplete_questions = random_questions(autocomplete_count, 'Autocomplete', difficulty)
    questions = choice_questions.to_a + true_false_questions.to_a + autocomplete_questions.to_a
    shuffled_questions = questions.shuffle
    shuffled_questions
  end

  # @!method random_questions
  # Fetches a random set of questions from the database.
  #
  # This method selects a random assortment of questions of a particular type and difficulty from the database.
  # It is used to assemble the pool of questions for the trivia game.
  #
  # @param question_count [Integer] The number of questions to retrieve.
  # @param question_type [String] The type of questions to retrieve ('Choice', 'True_False', or 'Autocomplete').
  # @param difficulty [Difficulty] The difficulty level of the questions to retrieve.
  # @return [ActiveRecord::Relation<Question>] A collection of question records.
  def random_questions(question_count, question_type, difficulty)
    difficulty.questions
              .where(type: question_type, is_question_translated: false)
              .order('RANDOM()')
              .limit(question_count)
  end

  # @!method create_translated_questions_and_answers
  # Creates translated versions of the provided questions and their answers.
  #
  # Iterates over a collection of questions, translating their text and associated help text.
  # Translated questions and their corresponding answers are then created in the database.
  #
  # @param trivia [Trivia] The trivia object for which questions are being translated.
  # @param questions [Array<Question>] An array of question objects to be translated.
  # @return [Array<Array, Array>] A two-element array containing the translated questions and answers.
  def create_translated_questions_and_answers(trivia, questions)
    translated_questions = []
    translated_answers = []
    questions.each do |question|
      translated_question_text = translate_to_selected_language(question.text, trivia.selected_language_code)
      translated_help_text = translate_to_selected_language(question.help, trivia.selected_language_code) if question.difficulty.level == 'beginner'
      translated_question = case question
                            when Choice
                              { 'question_type' => 'Choice', 'question' => Choice.create!(
                                text: translated_question_text,
                                difficulty: question.difficulty,
                                is_question_translated: true,
                                help: translated_help_text
                              ) }
                            when True_False
                              { 'question_type' => 'True_False', 'question' => True_False.create!(
                                text: translated_question_text,
                                difficulty: question.difficulty,
                                is_question_translated: true,
                                help: translated_help_text
                              ) }
                            end
      translated_questions << translated_question
      translated_question_answers = []
      answers = Answer.where(question: question)
      answers.each do |answer|
        is_an_autocomplete = answer.question.is_a?(Autocomplete)
        translated_answer_text = translate_to_selected_language(answer.text, trivia.selected_language_code) unless is_an_autocomplete
        translated_answer = if is_an_autocomplete
                              Answer.create!(text: translated_answer_text, question_id: translated_question['question']['id'])
                            else
                              Answer.create!(text: translated_answer_text, question_id: translated_question['question']['id'], correct: answer.correct)
                            end
        translated_question_answers << translated_answer
      end
      translated_answers << translated_question_answers
    end
    [translated_questions, translated_answers]
  end

  # @!method get_translated_questions
  # Retrieves a subset of questions for translation based on the difficulty level.
  #
  # This method selects a random set of questions that have not been translated yet,
  # limited to the number needed for a trivia game.
  #
  # @param difficulty [Difficulty] The difficulty level of the trivia game.
  # @return [ActiveRecord::Relation<Question>] A collection of question records ready for translation.
  def get_translated_questions(difficulty)
    difficulty.questions
              .where(type: %w[Choice True_False])
              .where(is_question_translated: false)
              .order('RANDOM()')
              .limit(5)
  end

  # @!method translate_to_selected_language(text, target_language)
  # Translates a given text to the selected language.
  #
  # This method sends a POST request to a translation API with the text to be translated and the target language.
  # It then parses the JSON response and returns the translated text.
  # If there is an error with the request or parsing the response, it outputs an error message and returns nil.
  #
  # @param [String] text The text to be translated.
  # @param [String] target_language The language to translate the text into.
  #
  # @return [String, nil] The translated text if successful, or nil if there was an error.
  #
  # @raise [StandardError] If there is an error with the request or parsing the response, it outputs an error message and returns nil.
  def translate_to_selected_language(text, target_language)
    url = URI('https://text-translator2.p.rapidapi.com/translate')

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request['content-type'] = 'application/x-www-form-urlencoded'
    request['X-RapidAPI-Key'] = ENV['TEXT_TRANSLATOR_KEY']
    request['X-RapidAPI-Host'] = 'text-translator2.p.rapidapi.com'
    query = URI.encode_www_form(
      source_language: 'es',
      target_language: target_language,
      text: text
    )
    request.body = query
    response = http.request(request)

    if response.code == '200'
      response_data = JSON.parse(response.body)

      if response_data.key?('data') && response_data['data'].key?('translatedText')
        return response_data['data']['translatedText']
      else
        puts "Error: No se encontró 'translatedText' en la respuesta."
        return nil
      end
    else
      puts "Error al traducir: #{response.message}"
      return nil
    end
  end

  # @!method post_trivia
  # Post endpoint that handles the initiation of a standard trivia game.
  #
  # This endpoint is responsible for setting up a new trivia game with standard questions.
  # It sets up the trivia using provided parameters and session information, and then
  # redirects the user to the first question of the trivia game.
  #
  # @param params [Hash] The parameters from the POST request, including difficulty level.
  # @param session [Hash] The session object to store trivia state.
  # @return [Redirect] A redirect to the first question of the new trivia game.
  post '/trivia' do
    setup_trivia(params, session, translate: false)
    redirect '/question/0'
  end

  # @!method post_trivia_traduce
  # Post endpoint that handles the initiation of a translated trivia game.
  #
  # This endpoint is responsible for setting up a new trivia game with questions translated
  # into the selected language. It sets up the trivia using provided parameters and session information,
  # including the language code for translations, and then redirects the user to the first question
  # of the translated trivia game.
  #
  # @param params [Hash] The parameters from the POST request, including difficulty level and selected language code.
  # @param session [Hash] The session object to store trivia state.
  # @return [Redirect] A redirect to the first question of the new translated trivia game.
  post '/trivia-traduce' do
    setup_trivia(params, session, translate: true)
    redirect '/question-traduce/0'
  end
end
