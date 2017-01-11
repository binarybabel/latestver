require_relative Rails.root.join('lib', 'rails_admin', 'reload_defaults.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::ReloadDefaults)

require_relative Rails.root.join('lib', 'rails_admin', 'refresh_catalog.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::RefreshCatalog)

require_relative Rails.root.join('lib', 'rails_admin', 'refresh_entry.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::RefreshEntry)

require_relative Rails.root.join('lib', 'rails_admin', 'trigger_webhook.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::TriggerWebhook)

RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :admin
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.authorize_with do
    unless Rails.application.secrets.admin_pass.to_s.empty?
      authenticate_or_request_with_http_basic('Login required') do |user, pass|
        user == Rails.application.secrets.admin_user && pass == Rails.application.secrets.admin_pass
      end
    end
  end

  config.browser_validations = false

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except ['CatalogLogEntry']
    end
    # export
    bulk_delete
    show
    edit do
      except ['CatalogLogEntry']
    end
    clone do
      except ['Group', 'Instance', 'CatalogLogEntry']
    end
    delete
    show_in_app

    refresh_catalog
    refresh_entry
    reload_defaults
    trigger_webhook
  end
end
