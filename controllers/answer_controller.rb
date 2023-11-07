require_relative '../server'
require_relative '../constants'

class AnswerController < Sinatra::Base
    include ServerConstants

    # @!method handle_answer
    # Method for handling answers to trivia questions.
    #
    # This method handles the submission of an answer to a trivia question. It checks if the answer is nil and if the question is not an Autocomplete question,
    # it calls the handle_unanswered_question method. Otherwise, it calls the process_answer method.
    #
    # @param [Integer] index The index of the current question.
    # @param [Question] question The current question object.
    # @param [Trivia] trivia The current trivia session.
    # @param [String] path_prefix The prefix of the redirect path.
    def handle_answer(index, question, trivia, path_prefix, params, session)
      selected_answer_id = params[:selected_answer]
      is_translated = trivia.selected_language_code != 'es'
      question_id = is_translated ? question['id'] : question.id
      selected_answer = Answer.find_by(id: selected_answer_id, question_id: question_id)

      if selected_answer.nil? && !question.is_a?(Autocomplete)
        handle_unanswered_question(index, path_prefix, session)
      else
        process_answer(selected_answer, index, question, question_id, trivia, path_prefix, params, session)
      end
    end

    # @!method process_answer
    # Method for processing answers.
    #
    # This method processes the submitted answer. It adds the index to the answered_questions session array,
    # calls the create_or_update_question_answer and handle_autocomplete_answer methods, and updates the response time.
    #
    # @param [Answer] selected_answer The selected answer object.
    # @param [Integer] index The index of the current question.
    # @param [Integer] question_id The ID of the current question.
    # @param [Trivia] trivia The current trivia session.
    # @param [String] path_prefix The prefix of the redirect path.
    def process_answer(selected_answer, index, question, question_id, trivia, path_prefix, params, session)
      session[:answered_questions] << index
      is_an_autocomplete = question.is_a?(Autocomplete)
      create_or_update_question_answer(selected_answer, question_id, trivia) unless is_an_autocomplete
      handle_autocomplete_answer(question, params, session) if is_an_autocomplete
      update_response_time(index, question_id, trivia, path_prefix, params)
    end

    # @!method create_or_update_question_answer
    # Method for creating or updating a QuestionAnswer record.
    #
    # This method creates or updates a QuestionAnswer record in the database with the IDs of the selected answer and question.
    # If a selected answer exists, it updates the answer_id of the QuestionAnswer record and sets the selected attribute of the Answer record to true.
    #
    # @param [Answer] selected_answer The selected answer object.
    # @param [Integer] question_id The ID of the current question.
    # @param [Trivia] trivia The current trivia session.
    def create_or_update_question_answer(selected_answer, question_id, trivia)
      question_answer = QuestionAnswer.find_or_initialize_by(question_id: question_id, trivia_id: trivia.id)

      return unless selected_answer

      question_answer.answer_id = selected_answer.id
      question_answer.save
      selected_answer.update(selected: true)
    end

    # @!method update_response_time
    # Method for updating the response time of a trivia question.
    #
    # This method calculates the response time based on the total time and the time taken by the user to respond.
    # It updates the response_time attribute of the QuestionAnswer record and redirects to the next question.
    #
    # @param [Integer] index The index of the current question.
    # @param [Integer] question_id The ID of the current question.
    # @param [Trivia] trivia The current trivia session.
    # @param [String] path_prefix The prefix of the redirect path.
    def update_response_time(index, question_id, trivia, path_prefix, params)
      total_time = trivia.difficulty == 'beginner' ? TIME_BEGINNER : TIME_DIFFICULTY
      response_time = total_time - params[:response_time].to_i
      question_answer = QuestionAnswer.find_by(question_id: question_id, trivia_id: trivia.id)
      question_answer&.update(response_time: response_time)

      next_index = index + 1
      redirect "#{path_prefix}/#{next_index}"
    end

    # @!method handle_autocomplete_answer
    # Method for handling answers to autocomplete questions.
    #
    # This method checks if the question is an Autocomplete question. If it is, it updates the autocomplete_input attribute of the Answer record.
    #
    # @param [Answer] selected_answer The selected answer object.
    # @param [Question] question The current question object.
    def handle_autocomplete_answer(question, params, session)
      autocomplete_input = params[:autocomplete_input].to_s.strip
      return unless question.is_a?(Autocomplete)

      answer_autocomplete = Answer.find_by(question_id: question.id)
      answer_autocomplete.update(autocomplete_input: autocomplete_input)
    end

    # @!method handle_unanswered_question
    # Method for handling unanswered questions.
    #
    # This method adds the index to the answered_questions session array and redirects to the next question.
    #
    # @param [Integer] index The index of the current question.
    # @param [String] path_prefix The prefix of the redirect path.
    #
    # @return [Redirect] Redirects to the next question.
    def handle_unanswered_question(index, path_prefix, session)
      session[:answered_questions] << index
      redirect "#{path_prefix}/#{index + 1}"
    end

    # @!method post_answer
    # POST endpoint for submitting an answer to a trivia question.
    #
    # This route handles the submission of an answer to a trivia question. It checks if the trivia session exists,
    # validates the submitted answer, and records the response time. Depending on the answer type (choice, true/false, or autocomplete),
    # it updates the appropriate tables in the database and redirects to the next question or results page.
    #
    # @param [Integer] index The index of the current question.
    #
    # @return [Redirect] Redirects to the next question or results page.
    #
    # @raise [Redirect] If there is no trivia in session, redirects to '/trivia'.
    # @raise [Redirect] If there are no more questions or if index is greater or equal to 10, redirects to '/results'.
    # @raise [Redirect] If the question has already been answered, redirects to '/error?code=answered'.
    post '/answer/:index' do
      @trivia = Trivia.find(session[:trivia_id])
      index = params[:index].to_i
      question = @trivia.questions[index]

      if question.nil? || index >= QUESTIONS_SPANISH
        redirect '/results'
      elsif session[:answered_questions].include?(index)
        redirect '/error?code=answered'
      else
        handle_answer(index, question, @trivia, '/question', params, session)
      end
    end

    # @!method post_answer_traduce
    # POST endpoint for submitting an answer to a translated trivia question.
    #
    # This route handles the submission of an answer to a translated trivia question. It checks if the trivia session exists,
    # validates the submitted answer, and records the response time. Depending on the answer type (choice, true/false, or autocomplete),
    # it updates the appropriate tables in the database and redirects to the next question or results page.
    #
    # @param [Integer] index The index of the current question.
    #
    # @return [Redirect] Redirects to the next question or results page.
    #
    # @raise [Redirect] If there is no trivia in session, redirects to '/trivia'.
    # @raise [Redirect] If there are no more questions or if index is greater or equal to 5, redirects to '/results-traduce'.
    # @raise [Redirect] If the question has already been answered, redirects to '/error?code=answered'.
    post '/answer-traduce/:index' do
      @trivia = Trivia.find(session[:trivia_id])
      index = params[:index].to_i
      question_hash = @trivia.translated_questions[index]

      if question_hash.nil? || index >= TRANSLATEDS_QUESTIONS
        redirect '/results-traduce'
      elsif session[:answered_questions].include?(index)
        redirect '/error?code=answered'
      else
        handle_answer(index, question_hash['question'], @trivia, '/question-traduce', params, session)
      end
    end
end
