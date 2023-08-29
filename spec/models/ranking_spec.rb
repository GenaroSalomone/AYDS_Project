require_relative '../../models/init.rb'
require 'sinatra/activerecord'

# Testing para modelo Ranking
describe Ranking do

  describe 'validations' do

    it "is invalid without a user ID" do
      ranking = Ranking.new(score: 0, difficulty_id: 1)
      expect(ranking.valid?).to eq(false)
    end

    it "is invalid without a difficulty ID" do
      ranking = Ranking.new(user_id: 1, score: 0)
      expect(ranking.valid?).to eq(false)
    end

    it "is valid with all required attributes" do
      ranking = Ranking.new(user_id: 1, score: 0, difficulty_id: 2)
      expect(ranking.valid?).to eq(true)
    end

    it 'is invalid if score is less than 0' do
      ranking = Ranking.new(user_id: 1, score: -1, difficulty_id: 2)
      expect(ranking).to be_invalid
      expect(ranking.errors[:score]).to include("must be between 0 and 100")
    end

    it 'is invalid if score is greater than 100' do
      ranking = Ranking.new(user_id: 1, score: 101, difficulty_id: 2)
      expect(ranking).to be_invalid
      expect(ranking.errors[:score]).to include("must be between 0 and 100")
    end

    it 'is valid if score is between 0 and 100' do
      ranking = Ranking.new(user_id: 1, score: 50, difficulty_id: 2)
      expect(ranking).to be_valid
    end

  end

  describe 'associations' do

    it "belongs to user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to trivia" do
      association = described_class.reflect_on_association(:trivia)
      expect(association.macro).to eq(:belongs_to)
    end

    it "belongs to difficulty" do
      association = described_class.reflect_on_association(:difficulty)
      expect(association.macro).to eq(:belongs_to)
    end

  end

end
