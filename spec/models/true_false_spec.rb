require_relative '../../models/init.rb'
require 'sinatra/activerecord'

# Testing para modelo True_False
describe True_False do
    
  describe 'validations' do
    
    it "is invalid without a text" do
      beginner_difficulty = Difficulty.create!(level: :beginner)
      trueFalse = True_False.new(difficulty: beginner_difficulty)
      expect(trueFalse.valid?).to eq(false)
    end

    it "is invalid without a difficulty ID" do
      trueFalse = True_False.new(text: "true_false question?")
      expect(trueFalse.valid?).to eq(false)
    end

  end
 
  describe 'associations' do
    
    it "has many question_answers" do
      association = described_class.reflect_on_association(:question_answers)
      expect(association.macro).to eq(:has_many)
    end

    it "has many answers" do
      association = described_class.reflect_on_association(:answers)
      expect(association.macro).to eq(:has_many)
    end

    it "belongs to difficulty" do
      association = described_class.reflect_on_association(:difficulty)
      expect(association.macro).to eq(:belongs_to)
    end

  end

end