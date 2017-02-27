namespace :intercom do
  desc 'update has_shared and has_snapmail for all intercom users'
  task :update_fields, [:DATABASE_URL, :app_id, :app_key, :user_id] do |_t, args|
    require 'intercom'
    ActiveRecord::Base.establish_connection("#{args[:DATABASE_URL]}")
    users = ActiveRecord::Base.connection.select_all("select * from users where id > #{args[:user_id]} order by id")

    intercom = Intercom::Client.new(
      app_id: args[:app_id],
      api_key: args[:app_key]
    )

    users.each do |user|
      begin
        ic_user = intercom.users.find(:user_id => user["username"])
      rescue Intercom::ResourceNotFound
        # Ignore it
      end
      unless ic_user.nil?
        has_shared = false
        has_snapmail = false
        if ActiveRecord::Base.connection.select_all("select * from camera_shares where sharer_id=#{user["id"]}").count > 0
          has_shared = true
        end
        if ActiveRecord::Base.connection.select_all("SELECT * FROM snapmails WHERE recipients like '%#{user["email"]}%'").count > 0
          has_snapmail = true
        end
        if has_shared || has_snapmail
          ic_user.custom_attributes = {"has_shared": has_shared, "has_snapmail": has_snapmail}
          intercom.users.save(ic_user)
          puts "Update user (#{user["id"]}): #{user["username"]}\t#{user["email"]}, has_shared=#{has_shared}, has_snapmail=#{has_snapmail}"
        else
          puts "Skip user (#{user["id"]}): #{user["username"]}\t#{user["email"]}"
        end
      end
    end
  end

  task :update_unknown_values, [:DATABASE_URL, :app_id, :app_key, :user_id] do |_t, args|
    require 'intercom'
    ActiveRecord::Base.establish_connection("#{args[:DATABASE_URL]}")
    users = ActiveRecord::Base.connection.select_all("select * from users where id > #{args[:user_id]} order by id")

    intercom = Intercom::Client.new(
        app_id: args[:app_id],
        api_key: args[:app_key]
    )

    users.each do |user|
      begin
        ic_user = intercom.users.find(:user_id => user["username"])
      rescue Intercom::ResourceNotFound
        # Ignore it
      end
      unless ic_user.nil?
        is_update = false

        if ic_user.custom_attributes["viewed_camera"].nil?
          is_update = true
          ic_user.custom_attributes = {"viewed_camera": 0}
        end
        if ic_user.custom_attributes["viewed_recordings"].nil?
          is_update = true
          ic_user.custom_attributes = {"viewed_recordings": 0}
        end
        if ic_user.custom_attributes["has_shared"].nil?
          is_update = true
          ic_user.custom_attributes = {"has_shared": false}
        end
        if ic_user.custom_attributes["has_snapmail"].nil?
          is_update = true
          ic_user.custom_attributes = {"has_snapmail": false}
        end
        if is_update
          intercom.users.save(ic_user)
          puts "Update user (#{user["id"]}): #{user["username"]}\t#{user["email"]}"
        end
      end
    end
  end
end
