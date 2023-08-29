require_relative '../../models/init.rb'
require 'sinatra/activerecord'

describe Question do
  describe 'validations' do
    let(:user) { User.new }
    let(:difficult_difficulty) { Difficulty.create!(level: "difficult") }

    it 'is valid when belongs to a subclass' do
      choice = Choice.create!( text: "¿Qué es un compilador?", difficulty: difficult_difficulty )
      attributes = choice.attributes.except("id")
      question = Question.create!( attributes )
      expect(question).to be_valid
    end

    it 'is invalid when not belongs to a subclass' do
      question = Question.new
      expect(question).to be_invalid
      expect(question.errors[:base]).to include('Question must belong to a subclass')
    end
  end
end
