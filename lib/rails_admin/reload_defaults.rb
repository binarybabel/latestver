module RailsAdmin
  class ReloadDefaults < RailsAdmin::Config::Actions::Base
    register_instance_option :visible? do
      Object.const_get(bindings[:abstract_model].to_s).respond_to? 'reload_defaults!'
    end

    register_instance_option :collection do
      true
    end

    register_instance_option :link_icon do
      'icon-wrench'
    end

    register_instance_option :pjax? do
      false
    end
  end
end
