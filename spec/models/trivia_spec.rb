require_relative '../../models/init.rb'
require 'sinatra/activerecord'

describe Trivia do
  describe 'validations' do
    let(:difficult_difficulty) { Difficulty.create!(level: "difficult") }

    it 'is invalid without a user' do
      trivia = Trivia.new(difficulty: difficult_difficulty)
      expect(trivia).to be_invalid
      expect(trivia.errors[:user]).to include("can't be blank")
    end

    it 'is invalid without a difficulty' do
      trivia = Trivia.new(user: User.new)
      expect(trivia).to be_invalid
      expect(trivia.errors[:difficulty]).to include("can't be blank")
    end

    it 'is valid with a user and a difficulty' do
      trivia = Trivia.new(user: User.new, difficulty: difficult_difficulty)
      expect(trivia).to be_valid
    end
  end
end
