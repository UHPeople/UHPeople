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
      join_duplicates(newest_msgs[i], most_new_users)
      join_duplicates(newest_msgs[i], most_usrs)
    end

    set_weights(newest_msgs)
    set_weights(most_new_users)
    set_weights(most_usrs)

    newest_msgs.concat(most_new_users).concat(most_usrs).first(20)
  end

  def set_weights(array)
    for j in 0..(array.length - 1)
      array[j][1] = 30 - j
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

  def join_duplicates(asd, array)
    for j in 0..(array.length - 1)
      if asd[0].equal? array[j][0]
        asd[1] = asd[1] + array[j][1]
        array[j][1] = 0
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
    to_sort.sort_by { |k| k[1] }.reverse!.first(30)
  end
end
