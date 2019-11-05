# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  scope 'user' do
    get '/', to: 'account#show'
    get '/transactions', to: 'transaction#index'
    post '/withdraw', to: 'account#withdraw'
    post '/deposit', to: 'account#deposit'
    post '/transfer', to: 'account#transfer'
    post '/login', to: 'user#login'
    post '/create', to: 'user#create'
    post '/archive', to: 'account#archive'
  end
end
