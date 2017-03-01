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
          ic_user.custom_attributes["viewed_camera"] = 0
        end

        if ic_user.custom_attributes["viewed_recordings"].nil?
          is_update = true
          ic_user.custom_attributes["viewed_recordings"] = 0
        end

        if ic_user.custom_attributes["has_shared"].nil?
          is_update = true
          ic_user.custom_attributes["has_shared"] = false
        end

        if ic_user.custom_attributes["has_snapmail"].nil?
          is_update = true
          ic_user.custom_attributes["has_snapmail"] = false
        end

        if is_update
          intercom.users.save(ic_user)
          puts "Update user (#{user["id"]}): #{user["username"]}\t#{user["email"]}, viewed_camera=#{ic_user.custom_attributes["viewed_camera"]},"+
                   "viewed_recordings=#{ic_user.custom_attributes["viewed_recordings"]}, has_shared=#{ic_user.custom_attributes["has_shared"]},"+
                   "has_snapmail=#{ic_user.custom_attributes["has_snapmail"]}"
        end
      end
    end
  end

  # task :save_duplicate_values_to_standard, [:app_id, :app_key] do |_t, args|
  #   require 'intercom'
  #   intercom = Intercom::Client.new(
  #       app_id: args[:app_id],
  #       api_key: args[:app_key]
  #   )

  #   intercom.users.all.each do |ic_user|
  #     is_update = false
  #     if ic_user.custom_attributes["job_title"].nil?
  #       is_update = true
  #       ic_user. = ic_user.custom_attributes["job_title"]
  #     end

  #     if ic_user.custom_attributes["viewed_recordings"].nil?
  #       is_update = true
  #       ic_user.custom_attributes["viewed_recordings"] = 0
  #     end

  #     if ic_user.custom_attributes["has_shared"].nil?
  #       is_update = true
  #       ic_user.custom_attributes["has_shared"] = false
  #     end

  #     if ic_user.custom_attributes["has_snapmail"].nil?
  #       is_update = true
  #       ic_user.custom_attributes["has_snapmail"] = false
  #     end
  #     if is_update
  #       puts %Q(Update user #{ic_user.email} - #{ic_user.user_id}, viewed_camera=#{ic_user.custom_attributes["viewed_camera"]},"+
  #                  "viewed_recordings=#{ic_user.custom_attributes["viewed_recordings"]}, has_shared=#{ic_user.custom_attributes["has_shared"]},"+
  #                  "has_snapmail=#{ic_user.custom_attributes["has_snapmail"]})
  #     end
  #   end
  # end

  task :add_companies, [:DATABASE_URL, :app_id, :app_key, :company_emails] do |_t, args|
    require 'intercom'
    ActiveRecord::Base.establish_connection("#{args[:DATABASE_URL]}")
    company_emails = args[:company_emails].split(" ").inject([]) { |list, entry| list << entry.strip }

    intercom = Intercom::Client.new(
        app_id: args[:app_id],
        api_key: args[:app_key]
    )

    company_emails.each do |company_email|
      puts "Start company #{company_email}"
      company = intercom.companies.find(:company_id => "#{company_email}")
      users = ActiveRecord::Base.connection.select_all("select * from users where email like '%@#{company_email}'")
      users.each do |user|
        begin
          ic_user = intercom.users.find(:user_id => user["username"])
        rescue Intercom::ResourceNotFound
          # Ignore it
        end
        unless ic_user.nil?
          # ic_user.companies = [{company_id: "#{args[:company_email]}", name: "#{args[:company_name]}"}]
          ic_user.companies = [{company_id: "#{company.company_id}"}]
          # intercom.users.save(ic_user)
          puts "Update user (#{user["id"]}): #{user["username"]}\t#{user["email"]}"
        end
      end
    end
  end
end
