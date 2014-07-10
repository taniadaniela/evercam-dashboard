ActiveAdmin.register_page "Dashboard" do

  menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("active_admin.dashboard_welcome.welcome")
        small I18n.t("active_admin.dashboard_welcome.call_to_action")
      end
    end

  end
end

ActiveAdmin.register_page "Cameras" do
  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Cameras" do
          table_for Camera.take(1000).map do |camera|
            column("ID", :sortable => :id)   {|camera| camera.id }
            column("Name", :sortable => :name)   {|camera| camera.name }

            column("Model")   {|camera| camera.model_id ? VendorModel.find(camera.model_id).name : '' }

            # column("Model")   {|camera| VendorModel.fnameind(camera.model_id).name }
            column("Owner")   {|camera| User.find(camera.owner_id).fullname }
            column("Public", :sortable => :is_public)   {|camera| camera.is_public }
            # column("config")   {|camera| camera.config.to_json }
            column("is_online", :sortable => :is_online)   {|camera| camera.is_online }
            column("discoverable", :sortable => :discoverable)   {|camera| camera.discoverable }
            column("Created", :sortable => :created_at)   {|camera| camera.created_at }
            column("Last Online", :sortable => :last_online_at)   {|camera| camera.last_online_at }
          end
        end
      end
    end
  end
end


ActiveAdmin.register_page "Snapshots" do
  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Snapshots" do

        end
      end
    end
  end
end


ActiveAdmin.register_page "Users" do
  content title: proc{ I18n.t("active_admin.dashboard") } do
    columns do
      column do
        panel "Users" do
          table_for User.all.map do |user|
            column("ID")   {|user| user.id }
            column("Name")   {|user| user.fullname}
            column("username")   {|user| user.username }
            column("email")   {|user| user.email }
            column("Country")   {|user| Country.find(user.country_id).name }
            column("Created")   {|user| user.created_at }
          end
        end
      end
    end
  end
end
