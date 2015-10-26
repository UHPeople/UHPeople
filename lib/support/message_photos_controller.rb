require 'json'
require 'erb'

# These two controllers shouldn't be in lib/
# They should be included in the correct controllers in app/controllers/

module MessagePhotosController
  def create_message_photo(message_id, photo_id)
    Message_photo.create message_id: message_id,
                         photo_id: photo_id
  end
end
