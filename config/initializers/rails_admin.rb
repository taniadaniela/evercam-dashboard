RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

# class RailsAdmin::Config::Fields::Types::Macaddr < RailsAdmin::Config::Fields::Base
#   RailsAdmin::Config::Fields::Types::register(self)
# end

module RailsAdmin
  module Config
    module Fields
      module Types
        class Macaddr < RailsAdmin::Config::Fields::Types::String
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)

          # @column_width = 60

          # register_instance_option(:partial) do
          #   "string"
          # end
        end
      end
    end
  end
end


config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
