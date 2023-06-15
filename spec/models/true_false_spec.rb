require_relative '../../models/init.rb'
require 'sinatra/activerecord'

# Prueba unitaria para modelo True_False

describe True_False do
  describe 'validations' do
    
    it "is invalid without text" do
      true_false = True_False.new(difficulty_id: 1, help: 'true_false_help')
      expect(true_false.valid?).to eq(false)
    end

    it "is invalid without difficulty_id" do
      true_false = True_False.new(text: 'true_false_text', help: 'true_false_help')
      expect(true_false.valid?).to eq(false)
    end

    it "is invalid with empty help in beginner difficulty" do
      true_false = True_False.new(text: 'true_false_text', help: '', difficulty_id: 2)
      expect(true_false.valid?).to eq(false)
    end

 end

   describe 'associations' do

    it 'has many question_answers' do
      association = described_class.reflect_on_association(:question_answers)
      expect(association.macro).to eq(:has_many)
    end
  
    it 'has many answers' do
      association = described_class.reflect_on_association(:answers)
      expect(association.macro).to eq(:has_many)
    end
  
    it 'belongs to a difficuty' do
      association = described_class.reflect_on_association(:difficulty)
      expect(association.macro).to eq(:belongs_to)
    end

  end

end