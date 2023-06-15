require_relative '../../models/init.rb'
require 'sinatra/activerecord'
require 'enumerize'

describe Difficulty do
  describe 'validations' do
    it "is valid with a valid level" do
      difficulty = Difficulty.new(level: :beginner)
      expect(difficulty.valid?).to eq(true)
    end

    it "is invalid with an invalid level" do
      difficulty = Difficulty.new(level: :intermediate)
      expect(difficulty.valid?).to eq(false)
    end
  end

  describe 'associations' do
    it "has many trivias" do
      difficulty = Difficulty.new(level: :beginner)
      trivia = difficulty.trivias.build
      expect(difficulty.trivias).to include(trivia)
    end

    it "has many questions" do
      difficulty = Difficulty.new(level: :beginner)
      question = difficulty.questions.build
      expect(difficulty.questions).to include(question)
    end

    it "has many choices" do
      difficulty = Difficulty.new(level: :beginner)
      choice = difficulty.choices.build
      expect(difficulty.choices).to include(choice)
    end

    it "has many true_falses" do
      difficulty = Difficulty.new(level: :beginner)
      true_false = difficulty.true_falses.build
      expect(difficulty.true_falses).to include(true_false)
    end

    it "has many autocompletes" do
      difficulty = Difficulty.new(level: :beginner)
      autocomplete = difficulty.autocompletes.build
      expect(difficulty.autocompletes).to include(autocomplete)
    end
  end

  describe 'enumerize' do
    it "assigns a valid level" do
      difficulty = Difficulty.new(level: :beginner)
      expect(difficulty.level).to eq(:beginner)
    end

    it "does not assign an invalid level" do
      difficulty = Difficulty.new(level: :intermediate)
      expect(difficulty).not_to be_valid
      expect(difficulty.errors[:level]).to include("is not included in the list")
    end

    it "assigns only permitted values using direct assignment" do
      difficulty = Difficulty.new
      difficulty.level = :advanced
      expect(difficulty).not_to be_valid
      expect(difficulty.errors[:level]).to include("is not included in the list")
    end

  end

end
