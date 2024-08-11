require_relative '../server'
require_relative '../constants'

class ResultsController < Sinatra::Base
  include ServerConstants
  set :views, File.expand_path('../views', __dir__)

  # Updates or creates the ranking for a user based on the given score and difficulty.
  #
  # This method checks if a ranking exists for the given user and difficulty level.
  # If a ranking doesn't exist or the new score is higher than the existing ranking score,
  # it creates a new ranking or updates the existing ranking with the higher score.
  # The method ensures that the user's highest score is always saved.
  #
  # @param user [User] the user for whom the ranking needs to be updated
  # @param ranking [Ranking, nil] the existing ranking record, or nil if it doesn't exist
  # @param difficulty [Difficulty] the difficulty level of the trivia
  # @param score [Integer] the new score to potentially update the ranking with
  # @return [Integer] the highest score achieved by the user for the given difficulty level
  # @see User
  # @see Ranking
  # @see Difficulty
  def update_ranking(user, ranking, difficulty, score)
    if ranking.nil? || score > ranking.score
      ranking = Ranking.find_or_initialize_by(user_id: user.id, difficulty_id: difficulty.id)
      ranking.score = [score, ranking.score].max
      ranking.save
    end
    ranking.score
  end

  # @!method calculate_response_time_score
  # Calculates the score for response time in a trivia game.
  #
  # This method takes the response time and response time limit as input and calculates the score based on how quickly
  # a question is answered. It assigns a maximum score of 10 points for a correct answer and deducts points based on
  # the time it took to respond. The deduction rate varies depending on the difficulty level.
  #
  # @param response_time [Integer] The time it took to respond to a question in seconds.
  # @param response_time_limit [Integer] The time limit allowed for responding to a question, which varies by difficulty.
  #
  # @return [Integer] The final score based on response time, clamped between 0 and a maximum of 10 points.
  private

  def calculate_response_time_score(response_time, response_time_limit)
    max_score = 10
    points_to_subtract = if response_time_limit == TIME_BEGINNER
                           [(response_time / 4).ceil, 3].min
                         else
                           [(response_time / 3).ceil, 3].min
                         end
    final_score = max_score - points_to_subtract
    final_score.clamp(0, max_score)
  end

  # Calculates the total score for the trivia based on the results and response times.
  #
  # Iterates over the results and adds scores for correct answers based on response time.
  # Calculates the total score for the trivia based on the results and response times.
  #
  # @param results [Array<Hash>] the results array from calculate_results
  # @param question_answers [Array<QuestionAnswer>] the list of question answers with response times
  # @param response_time_limit [Integer] the time limit for responding to questions
  # @return [Integer] the total score calculated from the results
  # @see QuestionAnswer
  def calculate_score(results, question_answers, response_time_limit)
    score = 0
    results.each_with_index do |result, idx|
      if result[:correct] && question_answers[idx].response_time <= response_time_limit
        response_time_score = calculate_response_time_score(question_answers[idx].response_time, response_time_limit)
        score += response_time_score
      else
        score += 0
      end
    end
    score
  end

  # Retrieves the current user and trivia difficulty level.
  #
  # This is a utility method to encapsulate the retrieval of the current user
  # and the difficulty level of the trivia they are playing.
  #
  # @return [Array] an array containing the current user and the trivia difficulty
  # @see User
  # @see Trivia
  def get_user_and_difficulty(session)
    user = User.find(session[:user_id]) if session[:user_id]
    difficulty = @trivia.difficulty
    [user, difficulty]
  end

  # Updates or creates the ranking for the user based on the difficulty and score.
  #
  # @param user [User] the current user
  # @param difficulty [Difficulty] the difficulty level of the trivia
  # @param score [Integer] the score to potentially update the ranking with
  # @return [Integer] the (new) score of the user's ranking
  # @see Ranking
  def update_user_ranking(user, difficulty, score)
    ranking = Ranking.find_by(user_id: user.id, difficulty_id: difficulty.id)
    new_score = update_ranking(user, ranking, difficulty, score)
    new_score
  end

  # Calculates the results of trivia questions.
  #
  # Iterates over the given question answers and determines whether the selected answer is correct.
  # Handles special logic for questions of type 'Autocomplete'.
  # Builds a results array with each question, selected answer, correct answer,
  # correctness, and any autocomplete input if applicable.
  #
  # @param question_answers [Array<QuestionAnswer>] the list of question answers to evaluate
  # @param response_time_limit [Integer] the time limit for responding to questions
  # @return [Array<Hash>] an array of result hashes for each question
  # @see QuestionAnswer
  # @see Answer
  def calculate_results(question_answers, response_time_limit)
    results = []
    question_answers.each do |question_answer|
      question = question_answer.question

      selected_answer = Answer.find_by(id: question_answer.answer_id, question_id: question_answer.question_id)
      correct_answer = Answer.find_by(question_id: question_answer.question_id, correct: true)

      result = {
        question: question,
        selected_answer: selected_answer,
        correct_answer: correct_answer,
        correct: false,
        autocomplete_input: nil
      }

      if question.is_a?(Autocomplete)
        answer = Answer.find_by(question_id: question.id)
        result[:correct] = answer.answers_autocomplete.include?(answer.autocomplete_input)
        result[:autocomplete_input] = answer.autocomplete_input
        result[:correct_answer] = answer.answers_autocomplete[0]
      else
        result[:correct] = selected_answer == correct_answer
      end

      results << result
    end
    results
  end

  # Sets up the view for results and calculates scores.
  #
  # This method consolidates the actions needed to set up the view for showing results.
  # It handles redirection if no trivia is in session, retrieves user and difficulty,
  # calculates results and score, and updates user ranking.
  #
  # @param offset [Integer, nil] the offset to start retrieving question answers (used for translated results)
  # @return [void]
  # @raise [Redirect] if there is no trivia in session, redirects to '/trivia'
  # @see QuestionAnswer
  # @see Answer
  # @see Trivia
  def setup_view_and_calculate_scores(offset = nil, session)
    redirect '/trivia' if @trivia.nil?
    @user = User.find(session[:user_id]) if session[:user_id]
    response_time_limit = @trivia.difficulty == 'beginner' ? TIME_BEGINNER : TIME_DIFFICULTY
    question_answers = offset ? @trivia.question_answers.offset(offset) : @trivia.question_answers
    @idx = 0
    @results = calculate_results(question_answers, response_time_limit)
    @score = calculate_score(@results, question_answers, response_time_limit)
    user, difficulty = get_user_and_difficulty(session)
    update_user_ranking(user, difficulty, @score)
  end

  # GET endpoint for displaying the results of the trivia.
  #
  # @!method get('/results')
  # This endpoint sets up the view for trivia results and calculates scores.
  # It renders the results template with the calculated results and scores.
  #
  # @return [ERB] the results template displaying trivia results
  # @see setup_view_and_calculate_scores
  get '/results' do
    if session[:user_id]
      @trivia = Trivia.find(session[:trivia_id])
      setup_view_and_calculate_scores(session)
      erb :results, locals: { results: @results, score: @score }
    else
      redirect '/login'
    end
  end

  # GET endpoint for displaying the results of the translated trivia.
  #
  # @!method get('/results-traduce')
  # This endpoint sets up the view for translated trivia results with an offset and calculates scores.
  # It renders the translated results template with the calculated results and scores.
  #
  # @return [ERB] the results_traduce template displaying translated trivia results
  # @see setup_view_and_calculate_scores
  get '/results-traduce' do
    @trivia = Trivia.find(session[:trivia_id])
    setup_view_and_calculate_scores(5, session)
    erb :results_traduce, locals: { results: @results, score: @score }
  end
end
