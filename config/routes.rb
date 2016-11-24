Rails.application.routes.draw do
  resources :payments do
    collection do
      post 'buckaroo_return' => 'payments#buckaroo_return', as: :buckaroo_return
      post 'buckaroo_callback' => 'payments#buckaroo_callback', as: :buckaroo_callback
      get 'buckaroo_mode/:mode' => 'payments#buckaroo_mode', as: :buckaroo_mode
    end
    member do
      post 'status' => 'payments#status', as: :status
      get 'recur' => 'payments#recur', as: :recur
      post 'recurrent' => 'payments#recurrent', as: :recurrent
    end
  end

  root to: 'payments#index'
end
