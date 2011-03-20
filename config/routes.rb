Cmg::Application.routes.draw do
  
  resources :samples

  match 'clubs' => 'registrations#index', :as => :clubs, :via => :get
  match 'clubs/:club_id' => 'registrations#show', :as => :club, :via => :get
  match 'clubs/:club_id/new' => 'registrations#new', :as => :registration, :via => :get
  match 'clubs/:club_id' => 'registrations#create', :as => :registration_create, :via => :post
  match 'clubs/:club_id/payment' => 'registrations#payment', :as => :registration_payment, :via => :get
  match 'clubs/:club_id/finalize' => 'registrations#finalize', :as => :registration_finalize, :via => :put
  match 'clubs/:club_id/regreport' => 'registrations#regreport', :via => :get
  # namespace :clubs, :controller => :registrations do
  #   match 'new' => :new, :as => :registration
  #   match 'create' => :create, :as => :registration_create
  #   match 'success' => :success, :as => :registration_success
  # end
  # resources :products, :only => [:index, :show] do
  #     member do
  #       get :download
  #       get :summary
  #       post :rate
  #       get :manifest
  #       get :tax
  #       post :buy_now
  #     end
  #     collection do
  #       get :summaries
  #       post :sync
  #     end
  

  
  match ':club_id' => 'registrations#show', :via => :get

  root :to => 'registrations#index', :via => :get


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
