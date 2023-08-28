require_relative '../../models/init.rb'
require 'sinatra/activerecord'

describe Answer do

  describe 'validations' do
    it "is invalid without a question_id" do
      answer = Answer.new(text: "Sample answer", correct: true)
      expect(answer.valid?).to eq(false)
    end

    it "is invalid without text" do
      answer = Answer.new(question_id: 1, text: nil, correct: false)
      expect(answer.valid?).to eq(false)
    end

    it "validates correct is true or false" do
      answer = Answer.new(question_id: 1, text: "Sample answer", correct: true)
      expect(answer.valid?).to eq(true)
    end

    it "validates maximum length of text" do
      answer = Answer.new(question_id: 1, text: "A" * 1000, correct: true)
      expect(answer.valid?).to eq(false)
    end

    it "is valid with valid attributes" do
      answer = Answer.new(question_id: 1, text: "Valid answer", correct: true)
      expect(answer.valid?).to eq(true)
    end

  end

  describe 'associations' do
    it "has many question_answers" do
      association = described_class.reflect_on_association(:question_answers)
      expect(association.macro).to eq(:has_many)
    end

    it "has many questions" do
      association = described_class.reflect_on_association(:questions)
      expect(association.macro).to eq(:has_many)
    end
  end

  describe 'custom methods' do
    it "returns true for correct answers" do
      correct_answer = Answer.new(question_id: 1, text: "Correct answer", correct: true)
      expect(correct_answer.correct?).to eq(true)
    end

    it "returns false for incorrect answers" do
      incorrect_answer = Answer.new(question_id: 1, text: "Incorrect answer", correct: false)
      expect(incorrect_answer.correct?).to eq(false)
    end
  end

end





