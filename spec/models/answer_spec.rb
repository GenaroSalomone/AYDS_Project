require_relative '../../models/init.rb'
require 'sinatra/activerecord'

# Prueba unitaria para answer
describe Answer do

  describe 'validations' do

    it "is invalid without question_id" do
      answer = Answer.new(text: 'answer_text', correct: false)
      expect(answer.valid?).to eq(false)
    end
    
    it "is invalid without text" do
      answer = Answer.new(question_id: 1, correct: false)
      expect(answer.valid?).to eq(false)
    end

 end

 # describe 'associatons' do

end

