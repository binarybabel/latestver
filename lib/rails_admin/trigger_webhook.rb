module RailsAdmin
  class TriggerWebhook < RailsAdmin::Config::Actions::Base
    register_instance_option :visible? do
      bindings[:object].class.to_s == 'CatalogWebhook'
    end

    register_instance_option :member do
      true
    end

    register_instance_option :link_icon do
      'icon-play'
    end

    register_instance_option :pjax? do
      false
    end
  end
end
