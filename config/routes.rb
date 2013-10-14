GeeFu::Application.routes.draw do
  devise_for :users, :controllers => { :registrations => "registrations" }

  root :to => "pages#index"
  
  get "/browse",     :to => "pages#browse" 
  get "/signed_up",  :to => "pages#signed_up", :as => :signed_up
  get 'begin' => 'pages#index'

  authenticate :user do
    resources :organisms
    resources :genomes
    resources :experiments
    resources :features
    resources :tools
    resources :admin

    scope "/features/search" do
      post "/id",        to: "features#search_by_id",         as: :feature_search_by_id
      post "/attribute", to: "features#search_by_attribute",  as: :feature_search_by_attribute
      post "/summary",   to: "features#summary",              as: :feature_search_by_range
    end

    scope "/tools" do
      post "/sequence",  to: "tools#genomic_sequence",        as: :tools_genomic_sequence
    end

    scope "/genomes" do
      get "/reference_list", to: "genomes#reference_list"
    end

    scope "/experiments" do
      get "/reference_list", to: "experiments#reference_list"
    end
  end

  scope "/features/annoj" do
    get  "/:id", to: "features#annoj_get"
    post "/:id", to: "features#annoj_post"
  end

  scope "/features/dalliance" do
  	get "/:exid", to: "features#dalliance_get"
    get "/reference/:exid", to:"features#dallience_reference"
    get "/reference/:exid'.xml'/sequence", to:"features#dallience_reference"
  end

  scope "/genomes/annoj" do
    get  "/:id", to: "genomes#annoj"
  end

  match '/admin/:id', :to => 'admin#show', :as => :user

 mount SequenceServer::App, :at => "sequenceserver"

match "/webapollo" => redirect("http://v0311.nbi.ac.uk:8080/WebApollo/"), :as => :webapollo


  # TODO review these for security
  resources :references
  match 'features/objects' => 'features#objects'
  match 'features/depth' => 'features#depth'
  match 'tools/genomic_sequence' => 'tools#genomic_sequence'
  match 'tools/export' => 'tools#export'
  match '/:controller(/:action(/:id))'
  # match ':controller/:action.:format' => '#index'
end
