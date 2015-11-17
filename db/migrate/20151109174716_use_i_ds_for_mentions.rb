class UseIDsForMentions < ActiveRecord::Migration
  def change
    Message.all.each do |message|
      next if message.content.nil?
      mentions = message.content.scan /@([a-z]+)/
      mentions.each do |user|
        id = User.find_by(username: user).try(:id)
        message.content.gsub!(user[0], id.to_s) if id.present?
        message.save
      end
    end

    # This is just a hotfix for cases where user didn't get generated tokens
    User.where(token: nil).each { |user| user.update_attribute(:token, :username) }
  end
end
