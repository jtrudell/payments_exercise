Rails.application.routes.draw do
  resources :loans, defaults: {format: :json} do
    resources :payments, only: [:index, :show, :create]
  end
end
