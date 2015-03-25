class TagcloudLogic
  def touch_cloud
    hashtags = Hashtag.all.map { |tag| [tag.tag, score(tag), tag.id] }
    top(hashtags)
  end

  def score(tag)
    new_messages = tag.messages.where('created_at >= ?', 1.week.ago).count
    new_users = tag.user_hashtags.where('created_at >= ?', 1.week.ago).count
    users = tag.user_hashtags.count

    (new_messages + new_users + users) / 3.0
  end

  def make_cloud(tag_array)
    tag_array.map do |tag|
      { text: tag[0], weight: tag[1], link: "/hashtags/#{tag[2]}" }
    end
  end

  def top(to_sort)
    to_sort.sort_by { |k| k[1] }.reverse!.first(30)
  end
end
