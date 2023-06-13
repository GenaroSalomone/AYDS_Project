require_relative '../../models/init.rb'
require 'sinatra/activerecord'

# Realiza una prueba unitaria en la clase User
describe User do
  describe 'validations' do
      it "is invalid without a username" do
        user = User.new(password: 'password', email: 'john@example.com')
        expect(user.valid?).to eq(false)
      end

    it "is invalid without a password" do
      user = User.new(username: 'john_doe', email: 'john@example.com')
      expect(user.valid?).to eq(false)
    end

    it "is invalid without an email address" do
      user = User.new(username: 'john_doe', password: 'password')
      expect(user.valid?).to eq(false)
    end

    it "is invalid with a duplicate email address" do
      existing_user = User.create(username: 'existing_user', email: 'john@example.com', password: 'password')
      user = User.new(username: 'john_doe', email: 'john@example.com', password: 'password')
      expect(user.valid?).to eq(false)
    end

    it "is invalid with a duplicate username" do
      existing_user = User.create(username: 'john_doe', email: 'existing_user@example.com', password: 'password')
      user = User.new(username: 'john_doe', email: 'john@example.com', password: 'password')
      expect(user.valid?).to eq(false)
    end
  end

  describe 'associations' do
    it 'has many trivias' do
      user = User.new
      expect(user).to respond_to(:trivias)
    end

    it 'has many rankings' do
      user = User.new
      expect(user).to respond_to(:rankings)
    end
  end
end

