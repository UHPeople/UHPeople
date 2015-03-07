require 'rails_helper'

describe User do
  it 'has name set correctly' do
    user = User.new name: 'Tero Testaaja'

    expect(user.name).to eq('Tero Testaaja')
  end

  it 'is saved with all needed variables' do
    user = User.create username: 'terotest', name: 'Tero Testaaja'

    expect(user.valid?).to be(true)
    expect(user.name).to eq('Tero Testaaja')
    expect(user.username).to eq('terotest')
    expect(User.count).to eq(1)
  end

  it 'is not saved without name' do
    user = User.create username: 'terotest'

    expect(user.valid?).to be(false)
    expect(User.count).to eq(0)
  end
end
