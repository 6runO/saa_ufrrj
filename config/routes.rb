Rails.application.routes.draw do
  root to: 'pages#home'
  post 'upload', to: 'pages#upload', as: :upload
  get 'normativa', to: 'pages#normativa', as: :normativa
  get 'about', to: 'pages#about', as: :about
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
