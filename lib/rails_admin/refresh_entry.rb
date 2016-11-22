module RailsAdmin
  class RefreshEntry < RailsAdmin::Config::Actions::Base
    register_instance_option :visible? do
      bindings[:object].respond_to? 'refresh!'
    end

    register_instance_option :member do
      true
    end

    register_instance_option :link_icon do
      'icon-refresh'
    end

    register_instance_option :pjax? do
      false
    end
  end
end
