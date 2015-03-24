class TagcloudLogic
  def touch_cloud
    newest_msgs = []
    most_new_users = []
    most_usrs = []

    make_arrays(most_new_users, most_usrs, newest_msgs)

    newest_msgs = sort_and_first(newest_msgs)
    most_new_users = sort_and_first(most_new_users)
    most_usrs = sort_and_first(most_usrs)

    for i in 0..(newest_msgs.length - 1)
      find_duplicates(i, most_new_users, newest_msgs)
      find_duplicates(i, most_usrs, newest_msgs)
    end

    set_weights(newest_msgs)
    set_weights(most_new_users)
    set_weights(most_usrs)

    newest_msgs.concat(most_new_users)
    newest_msgs.concat(most_usrs)
    newest_msgs.sort_by { |k| k[1] }

    newest_msgs.first(20)
  end

  def set_weights(tag)
    for j in 0..(tag.length - 1)
      tag[j][1] = 30 - j
    end
  end

  def make_arrays(most_new_users, most_usrs, newest_msgs)
    Hashtag.find_each do |tag|
      name = tag.tag
      new_messages = tag.messages.where('created_at >=?', 1.week.ago).count
      new_users = tag.user_hashtags.where('created_at >=?', 1.week.ago).count
      users = tag.users.count
      newest_msgs << [name, new_messages, tag.id]
      most_new_users << [name, new_users, tag.id]
      most_usrs << [name, users, tag.id]
    end
  end

  def find_duplicates(i, most_new_users, newest_msgs)
    for j in 0..(most_new_users.length - 1)
      if newest_msgs[i][0].equal? most_new_users[j][0]
        newest_msgs[i][1] = newest_msgs[i][1] + most_new_users[j][1]
        most_new_users[j][1] = 0
      end
    end
  end

  def make_cloud(tag_array)
    word_array = []
    tag_array.each do |tag|
      word_array.push(text: tag[0], weight: tag[1], link: "/hashtags/#{tag[2]}")
    end
    word_array
  end

  def sort_and_first(to_sort)
    to_sort = to_sort.sort_by { |k| k[1] }.reverse!
    to_sort.first(30)
  end
end
