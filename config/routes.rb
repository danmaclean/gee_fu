GeeFu::Application.routes.draw do
  resources :organisms


  resources :genomes
  resources :organisms
  resources :organisms
  resources :features
  resources :genomes
  resources :experiments
  resources :references
  resources :tools
  match 'features/objects' => 'features#objects'
  match 'features/depth' => 'features#depth'
  match 'tools/genomic_sequence' => 'tools#genomic_sequence'
  match 'tools/export' => 'tools#export'
  match 'begin' => 'organisms#index'
  match '/:controller(/:action(/:id))'
  match ':controller/:action.:format' => '#index'
end
