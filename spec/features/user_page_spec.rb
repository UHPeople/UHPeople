require 'rails_helper'

RSpec.describe User do
  context 'Profile page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }
    let!(:photo) { FactoryGirl.create(:photo, user_id: user.id) }

    before :each do
      visit "/login/#{user.id}"
      visit "/hashtags/#{hashtag.tag}"
      click_link 'add'

      visit "/users/#{user.id}"
    end

    it 'has name' do
      expect(page).to have_content 'asd asd'
    end

    it 'has email' do
      expect(page).to have_content 'asd@asd.fi'
    end

    it 'has campus' do
      expect(page).to have_content 'Viikki'
    end

    it 'has about' do
      expect(page).to have_content 'abouttest!!212'
    end

    it 'has hashtags' do
      expect(page).to have_content '#avantouinti'
    end

    it "doesn't have interests title if no hashtags" do
      visit "/hashtags/#{hashtag.tag}"
      first('.leave-button').click
      visit "/users/#{user.id}"

      expect(page).not_to have_content 'Interests'
    end

    it 'doesn´t have active channels if should not' do
      visit "/users/#{user.id}"
      expect(page).not_to have_content 'Most active'
      expect(page).to have_content 'Other'
    end

    it 'has active channels if has' do
      Message.create content: 'asd', hashtag_id: hashtag.id, user_id: user.id

      visit "/users/#{user.id}"
      expect(page).to have_content 'Most active'
      expect(page).not_to have_content 'Other'
    end

    it 'has in common button if same hashtag' do
      u2 = described_class.create name: 'asd asd', username: 'asd2', email: 'asd@asd.fi', campus: 'Viikki', about: 'abouttest!!212', first_time: false
      u2.hashtags << hashtag
      visit "/users/#{u2.id}"
      expect(page).to have_content 'You have 1'
    end

    it 'doesn´t have common button if on current_user page' do
      visit "/users/#{user.id}"
      expect(page).not_to have_content 'You have'
    end

    it 'doesn´t have common button if no common' do
      u2 = described_class.create name: 'asd asd', username: 'asd2', email: 'asd@asd.fi', campus: 'Viikki', about: 'abouttest!!212', first_time: false

      visit "/users/#{u2.id}"
      expect(page).not_to have_content 'You have'
    end

    context 'Photos tab', js: true do
      before :each do
        click_link 'Photos'
      end

      it 'has button for adding photos' do
        expect(page).to have_content 'add'
      end

      it 'can add photos to album' do
        last_photo = Photo.last.id
        execute_script "$('#image').show();"
        attach_file('image', File.absolute_path('./app/assets/images/bg.jpg'))

        expect Photo.last.id == last_photo + 1
        expect Photo.last.user_id == user.id
        expect(page).to have_xpath("//a[@id='" + Photo.last.id.to_s + "']")
        expect(page).to have_css ('.card-image')
      end

      it 'can fail upload to album if not image file' do
        last_photo = Photo.last.id
        execute_script "$('#image').show();"
        attach_file('image', File.absolute_path('./app/assets/javascripts/chat.coffee'))

        expect Photo.last.id == last_photo
      end

      context 'photo gallery', js: true do
        before :each do
          click_link 'Photos'
        end

        it 'has one photo in gallery' do
          expect(page).to have_xpath("//a[@id='" + photo.id.to_s + "']")
          expect(page).to have_css ('.card-image')
        end

        it 'has full screen photo' do
          click_link photo.id
          expect(page).to have_css ('.overlay-card')
        end

        it 'has photo edit menu' do
          click_link photo.id
          expect(page).to have_css ('button#menu' + photo.id.to_s)
        end

        it 'has delete photo button' do
          click_link photo.id
          click_button 'menu' + photo.id.to_s
          expect(page).to have_content 'Delete photo'
        end

        # it 'delete photo button does delete' do
        #   click_link photo.id
        #   click_button "menu" + photo.id.to_s
        #   click_link 'Delete photo'
        #   expect(page).to have_content 'Photo was successfully deleted.'
        # end
      end
    end
  end
end
