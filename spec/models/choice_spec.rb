require_relative '../../models/init.rb'
require 'sinatra/activerecord'

# Se realiza la prueba unitaria para la clase Choice
describe Choice do

  describe 'validations' do

    it "is invalid without text" do
      choice = Choice.new(difficulty_id: 1, help: 'choice_help')
      expect(choice.valid?).to eq(false)
    end

    it "is invalid without difficulty_id" do
      choice = Choice.new(text: 'choice_text', help: 'choice_help')
      expect(choice.valid?).to eq(false)
    end

    it "is invalid with empty help for beginner difficulty" do
      choice = Choice.new(text: 'choice_text', difficulty_id: 1, help: '')
      expect(choice.valid?).to eq(false)
    end

  end

  describe 'associations' do

    #el metodo descibed_class.reflect_on_association significa,
    # described_class, hace referencia a la clase descrita (Choice en este caso)
    # reflect_on_association, obtiene informacion con respecto a la asociaciones del modelo

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
