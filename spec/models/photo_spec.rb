require 'rails_helper'

RSpec.describe Photo do
  file = File.new(File.join(Rails.root, '/spec/fixtures/paperclip', 'blank.jpg'), 'rb')

  it 'has title' do
    photo = described_class.new image_text: 'Testikuva'
    expect(photo.image_text).to eq('Testikuva')
  end

  it 'is saved with all needed variables' do
    photo = described_class.create!(user_id: '1', image: file)
    assert_equal 'blank.jpg', photo.image_file_name
  end

  it 'is not saved without user id' do
    photo = described_class.create(image: file)
    expect(photo.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end
end
