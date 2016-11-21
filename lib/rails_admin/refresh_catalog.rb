module RailsAdmin
  class RefreshCatalog < RailsAdmin::Config::Actions::Base
    register_instance_option :visible? do
      bindings[:abstract_model].to_s == 'CatalogEntry'
    end

    register_instance_option :collection do
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
