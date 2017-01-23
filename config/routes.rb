Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'dashboard#index'

  get 'catalog' => 'catalog#index', :as => 'catalog'
  get 'catalog/:name/:tag' => 'catalog#view', :as => 'catalog_view',
      :name => /[a-z0-9\._-]+?/, :tag => /[a-z0-9\._-]+?/, :format => /html/
  get 'catalog-api/:name/:tag' => 'catalog#view', :as => 'catalog_view_api',
      :name => /[a-z0-9\._-]+?/, :tag => /[a-z0-9\._-]+?/, :format => /txt|json|svg/

  get 'group/:group' => 'group#index', :as => :group
  post 'group/:group' => 'group#update', :as => :group_update

  get 'log' => 'log#index', :as => 'log', :format => /html|rss/
  get 'help' => 'help#index', :as => 'help'
  get 'api' => 'help#api', :as => 'api'
  get 'ver' => 'help#version', :as => nil
end
