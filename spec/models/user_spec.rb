require 'rails_helper'

RSpec.describe User do
  it 'has name set correctly' do
    user = described_class.new name: 'Tero Testaaja'

    expect(user.name).to eq('Tero Testaaja')
  end

  it 'is saved with all needed variables' do
    user = described_class.create username: 'terotest', name: 'Tero Testaaja', campus: 'testcampus'

    expect(user.valid?).to be(true)
    expect(user.name).to eq('Tero Testaaja')
    expect(user.username).to eq('terotest')
    expect(user.campus).to eq('testcampus')
    expect(described_class.count).to eq(1)
  end

  it 'is not saved without name' do
    user = described_class.create username: 'terotest'

    expect(user.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end
end
