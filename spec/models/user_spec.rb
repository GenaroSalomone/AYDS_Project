require_relative '../../models/init.rb'

# Realiza una prueba unitaria en la clase User
# Se inicializa las columnas de la tabla User en nil y se almace el registro en u
describe 'User' do
  describe 'valid' do
    describe 'when there is no name' do
      it 'should be invalid' do
        u = User.new
        expect(u.valid?).to eq(false)
      end
    end
  end
end

# Se definen pruebas unitarias para la clase User
describe User do
  it "is valid with a firstname, lastname and email"
  it "is invalid without a firstname"
  it "is invalid without a lastname"
  it "is invalid without an email address"
  it "is invalid with a duplicate email address"
  it "returns a contact's full name as a string"
end