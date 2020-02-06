# frozen_string_literal: true

require 'api_constraints.rb'

Rails.application.routes.draw do
  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true), path: 'v1' do
      post 'login', controller: :authentication, action: :authenticate
      post 'register', controller: :users, action: :create
      get 'user', controller: :users, action: :show
      put 'user', controller: :users, action: :update
      delete 'user', controller: :users, action: :destroy
      get 'accounts/inactive', to: 'accounts#inactive'
      put 'accounts/:id/deactivate', to: 'accounts#deactivate'
      put 'accounts/:id/activate', to: 'accounts#activate'
      resources :accounts do
        resources :transactions
      end
    end
  end
end
