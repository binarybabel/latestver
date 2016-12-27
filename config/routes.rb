Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root 'dashboard#index'

  get 'catalog' => 'catalog#index', :as => 'catalog'
  get 'catalog/:name/:tag' => 'catalog#view', :as => 'catalog_view'
  get 'catalog-api/:name/:tag' => 'catalog#view', :as => 'catalog_view_api'

  get 'group/:group' => 'group#index', :as => :group
  post 'group/:group' => 'group#update', :as => :group_update

  get 'log' => 'log#index', :as => 'log'
  get 'help' => 'help#index', :as => 'help'
  get 'api' => 'help#api', :as => 'api'
  get 'ver' => 'help#version', :as => nil
end
