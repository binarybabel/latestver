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
    reload_defaults
    refresh_entry
    trigger_webhook
  end
end

module RailsAdmin
  module Config
    module Fields
      class Association < RailsAdmin::Config::Fields::Base
        register_instance_option :pretty_value do
          v = bindings[:view]
          [value].flatten.select(&:present?).collect do |associated|
            amc = polymorphic? ? RailsAdmin.config(associated) : associated_model_config # perf optimization for non-polymorphic associations
            am = amc.abstract_model
            wording = associated.send(amc.object_label_method)
            can_see = false #!am.embedded? && (show_action = v.action(:show, am, associated))
            can_see ? v.link_to(wording, v.url_for(action: show_action.action_name, model_name: am.to_param, id: associated.id), class: 'pjax') : ERB::Util.html_escape(wording)
          end.to_sentence.html_safe
        end
      end
    end
  end
end
