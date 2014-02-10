GeeFu::Application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}

  root :to => "pages#index"

  #get "/browse", :to => "experiments#index"
  get "/signed_up", :to => "pages#signed_up", :as => :signed_up
  get 'begin' => 'pages#index'

  authenticate :user do
    #resources :organisms
    #resources :genomes
    #resources :experiments
    #resources :features
    resources :tools
    resources :admin
  end

  resources :organisms
  resources :genomes
  resources :experiments
  resources :features

  scope "features" do
    get "/getgroup/:id", to: "features#getIdFromGroup"
  end

  scope "/features/search" do
    post "/id", to: "features#search_by_id", as: :feature_search_by_id
    post "/attribute", to: "features#search_by_attribute", as: :feature_search_by_attribute
    post "/summary", to: "features#summary", as: :feature_search_by_range
    get "/genome/typeahead", to: "features#genome_typeahead"
    get "/experiment/typeahead", to: "features#experiment_typeahead"
    post "/build", to: "features#display_all_by_build", as: :feature_display_all_by_build
  end

  scope "/tools" do
    post "/sequence", to: "tools#genomic_sequence", as: :tools_genomic_sequence
  end



  scope "/genomes" do
    get "/reference_list", to: "genomes#reference_list"
  end

  scope "/experiments" do
    get "/reference_list", to: "experiments#reference_list"
    get "/:id/:segment", to: "experiments#show"
  end

  scope "/features/dalliance" do
    get "/part/:exid/:part", to: "features#dalliance_part"
    get "/:exid/:part", to: "features#dalliance_get"
    get "/:exid/:part/:featutype/", to: "features#dalliance_get"
  end

  scope "/genomes/dalliance/" do
    get "/:exid/:part/sequence", to: "features#dalliance_genome"
    get ":experiment/:sequence/entry_points", to: "features#entrypoints"
  end

  scope "/users" do
    get "/admin", to: "admin#index"
  end

  scope "/badges" do
    get "/badge/:badge", to: "Pages#getbadge"
    # get "/card/:email/:badge", to: "Pages#getcard"
  end

match "/badges/card/:email/:badge" => "Pages#getcard",
    :constraints => { :email => /.+@.+\..*/ }

  scope "/genomes/annoj" do
    get "/:id", to: "genomes#annoj"
  end

  match '/admin/:id', :to => 'admin#show', :as => :user

  mount SequenceServer::App, :at => "sequenceserver"

  scope "/sequenceserver" do
    get "/get_sequence", to: "experiments#findfromss"
  end

  # match "/webapollo" => redirect("http://geefu.oadb.tsl.ac.uk:8080/WebApollo/"), :as => :webapollo
  # match "/webapollo2" => redirect("http://geefu.oadb.tsl.ac.uk:8080/WebApollo2/"), :as => :webapollo2


require 'gollum/frontend/app'

  Precious::App.set(:gollum_path, Rails.root.join('wiki').to_s)
  Precious::App.set(:default_markup, :markdown) # set your favorite markup language
  Precious::App.set(:wiki_options, {:universal_toc => false})
  mount Precious::App, at: 'wiki'


# TODO review these for security
  resources :references
  match 'features/objects' => 'features#objects'
  match 'features/depth' => 'features#depth'
  match 'tools/genomic_sequence' => 'tools#genomic_sequence'
  match 'tools/export' => 'tools#export'
  match '/:controller(/:action(/:id))'
end
