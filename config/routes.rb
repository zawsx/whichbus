WhichbusSpine::Application.routes.draw do

  match '*all' => 'application#cor', :constraints => {:method => 'OPTIONS'}

  get "pages/index"

  match '/spine' => 'pages#index'

  match '/about' => 'about#index'
  match '/about/:action' => 'about#:action'
  # If we choose to add more pages without updating routes, use this approach
    #match '/about' => 'about#whichbus'
    #match '/privacy' => 'about#privacy'
    #match '/terms' => 'about#terms'
    #match '/issues' => 'about#issues'

  scope '/workshop' do
    match '' => 'application#search', :as => :workshop
    match '/search' => 'application#search'
    match '/stops/nearby' => 'stops#nearby', format: 'json'

    # RESTful resources
    resources :agencies
    resources :routes do
      member do
        get 'stops', format: 'json'
        get 'trips', format: 'json'
      end
    end
    resources :stops do
      member do
        get 'routes', format: 'json'
        get 'arrivals', format: 'json'
        get 'schedules', format: 'json'
      end
    end

    # OTP ID routes
    match '/stops/:agency/:code/arrivals' => 'stops#arrivals_otp', format: 'json'
    match '/routes/:agency/:code/trips' => 'routes#trips_otp', format: 'json'
    match '/agencies/otp/:code' => 'agencies#show_otp'
    match '/routes/:agency/:code' => 'routes#show_otp'
    match '/stops/:agency/:code' => 'stops#show_otp'
  end

  scope '/api' do
    # API methods, they return json by default
    match '/otp/:method(/:agency/:id)' => 'application#otp', format: 'json'

    match '/oba/:method(/:id)' => 'application#oba', format: 'json'
  end

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
  root :to => 'application#index'

  # Add a test page for non-production environments.
  if not Rails.env.production?
    match '/test', to: 'application#test'
  end

  # Catch all route for the Backbone
  match '*path', to: 'application#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
