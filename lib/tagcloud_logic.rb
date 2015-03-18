class TagcloudLogic
  def count_cloud
    fresh_msgs = []
    so_new_usrs = []
    much_usrs = []

    Hashtag.find_each do |tag|
      name = tag.tag
      new_messages = tag.messages.where("created_at >=?", 1.week.ago).count
      new_users = tag.user_hashtags.where("created_at >=?", 1.week.ago).count
      users = tag.users.count
      fresh_msgs << [name, new_messages, tag.id]
      so_new_usrs << [name, new_users, tag.id]
      much_usrs << [name, users, tag.id]
    end

    fresh_msgs.sort_by{|k|k[1]}
    fresh_msgs.first(30)
    fms = fresh_msgs.length-1
    so_new_usrs.sort_by{|k|k[1]}
    so_new_usrs.first(30)
    snus = so_new_usrs.length-1
    much_usrs.sort_by{|k|k[1]}
    much_usrs.first(30)
    mus = much_usrs.length-1

    for i in 0..fms
      for j in 0..snus
        if fresh_msgs[i][0].equal? so_new_usrs[j][0]
          fresh_msgs[i][1] = fresh_msgs[i][1] + so_new_usrs[j][1]
          so_new_usrs[j][1] = 0
        end
      end
      for j in 0..mus
        if fresh_msgs[i][0].equal? much_usrs[j][0]
          fresh_msgs[i][1] = fresh_msgs[i][1] + much_usrs[j][1]
          much_usrs[j][1] = 0
        end
      end
    end

    fresh_msgs.concat(so_new_usrs)
    fresh_msgs.concat(much_usrs)
    fresh_msgs.sort_by{|k|k[1]}

    return fresh_msgs.first(30)
  end

  def make_cloud(tag_array)
    word_array = []
    for i in 0..(tag_array.size-1)
      word_array.push({text: tag_array[i][0], weight: tag_array[i][1], link: "/hashtags/#{tag_array[i][2]}"})
    end
    return word_array
  end

end

