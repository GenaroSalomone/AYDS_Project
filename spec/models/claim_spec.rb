require_relative '../../models/init.rb'
require 'sinatra/activerecord'

describe Claim do
    
  describe 'validations' do
    
    it "is invalid without a description" do
      claim = Claim.new(user_id: "1")
      expect(claim.valid?).to eq(false)
    end

    it "is invalid without a user ID" do
      claim = Claim.new(description: "This is a cool App.")
      expect(claim.valid?).to eq(false)
    end

    it "is valid with all atributes required" do
      claim = Claim.new(description: "This is other cool App.", user_id: "2")
      expect(claim.valid?).to eq(true)
    end

  end

  describe 'associations' do
  
    it "belongs to user" do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq(:belongs_to)
    end

  end

end