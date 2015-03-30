class TagcloudLogic
  def make_cloud
    hashtags = Hashtag.joins(:user_hashtags)
              .includes(:messages, :user_hashtags).all.map do |tag|
      { text: tag.tag, weight: score(tag), link: "/hashtags/#{tag.id}" }
    end

    top(hashtags)
  end

  def score(tag)
    new_messages = tag.messages.where('created_at >= ?', 1.week.ago).count
    new_users = tag.user_hashtags.where('created_at >= ?', 1.week.ago).count
    users = tag.user_hashtags.count

    (2 * new_messages + new_users + users) / 4.0
  end

  def top(to_sort)
    to_sort.sort_by { |k| k[:weight] }.reverse!.first(30)
  end
end
