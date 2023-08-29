require_relative '../../models/init.rb'
require 'sinatra/activerecord'

describe QuestionAnswer do

  describe 'validations' do
    let(:user) { User.new }
    let(:difficult_difficulty) { Difficulty.create!(level: "difficult") }
    let(:question) { Question.create!(text: 'question', difficulty: difficult_difficulty, type: 'Choice') }
    let(:answer) { Answer.create!(question: question, text: 'text', correct: true) }
    let(:trivia) { Trivia.create!(user: user, difficulty: difficult_difficulty) }

    it "validates uniqueness of question_id, answer_id, and trivia_id combination" do
      QuestionAnswer.create!(question_id: question.id, answer_id: answer.id, trivia_id: trivia.id)
      duplicate_question_answer = QuestionAnswer.new(question_id: question.id, answer_id: answer.id, trivia_id: trivia.id)
      expect(duplicate_question_answer).not_to be_valid
    end

    it "validates presence of associated question, answer, and trivia" do
      question_answer = QuestionAnswer.new
      expect(question_answer).not_to be_valid
      expect(question_answer.errors[:base]).to include("Question, answer, and trivia must be present")
    end

    it "validates that question and trivia have the same difficulty" do
      inconsistent_trivia = Trivia.create!(user: user, difficulty: Difficulty.create!(level: "beginner"))
      inconsistent_question_answer = QuestionAnswer.new(question: question, answer: answer, trivia: inconsistent_trivia)
      expect(inconsistent_question_answer).not_to be_valid
      expect(inconsistent_question_answer.errors[:base]).to include("Question and trivia must have the same difficulty")
    end

    it "validates that question and trivia with the same difficulty are valid" do
      consistent_question_answer = QuestionAnswer.new(question: question, answer: answer, trivia: trivia)
      expect(consistent_question_answer).to be_valid
    end
  end

end
