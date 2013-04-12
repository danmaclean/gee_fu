GeeFu::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }

  root :to => "pages#index"
  
  get "/browse",     :to => "pages#browse" 
  get "/signed_up",  :to => "pages#signed_up", :as => :signed_up

  authenticate :user do
    resources :organisms
    resources :genomes
    resources :experiments
    match 'begin' => 'pages#index'

  end

  scope "/features/annoj" do
    get  :id, to: "features#annoj_get"
    post :id, to: "features#annoj_post"
  end

  resources :features
  resources :references
  resources :tools
  match 'features/objects' => 'features#objects'
  match 'features/depth' => 'features#depth'
  match 'tools/genomic_sequence' => 'tools#genomic_sequence'
  match 'tools/export' => 'tools#export'
  match '/:controller(/:action(/:id))'
  match ':controller/:action.:format' => '#index'
end
