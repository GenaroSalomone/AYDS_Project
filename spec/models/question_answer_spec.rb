require_relative '../../models/init.rb'
require 'sinatra/activerecord'

describe QuestionAnswer do
  let(:question) { Question.create(text: 'Question') }
  let(:answer) { Answer.create(text: 'Answer') }
  let(:user) { User.create(username: 'genaro', password: '123456', email: 'gena@gmail.com') }
  let(:trivia) { Trivia.create(user: user) }

  describe 'associations' do
    it "belongs to a question" do
      question_answer = QuestionAnswer.new(question: question, answer: answer, trivia: trivia)
      expect(question_answer.question).to eq(question)
    end

    it "belongs to an answer" do
      question_answer = QuestionAnswer.new(question: question, answer: answer, trivia: trivia)
      expect(question_answer.answer).to eq(answer)
    end

    it "belongs to a trivia" do
      question_answer = QuestionAnswer.new(question: question, answer: answer, trivia: trivia)
      expect(question_answer.trivia).to eq(trivia)
    end
  end

  describe 'validations' do
    it "is valid with all required attributes" do
      question_answer = QuestionAnswer.new(question: question, answer: answer, trivia: trivia)
      expect(question_answer.valid?).to eq(true)
    end

    it "is invalid without a question" do
      question_answer = QuestionAnswer.new(answer: answer, trivia: trivia)
      expect(question_answer.valid?).to eq(false)
    end

    it "is invalid without an answer" do
      question_answer = QuestionAnswer.new(question: question, trivia: trivia)
      expect(question_answer.valid?).to eq(false)
    end

    it "is invalid without a trivia" do
      question_answer = QuestionAnswer.new(question: question, answer: answer)
      expect(question_answer.valid?).to eq(false)
    end
  end
end
