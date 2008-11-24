ActionController::Routing::Routes.draw do |map|
  map.resources :clone_trees

  map.resources :doc_versions

  map.resources :invitations
  
  map.resources :images
  
  map.resources :users, :member => { :related_projects => :get  } do |users|
    users.resources :doc_versions
  end
  
  map.resources :projects, :member => { :follow => :get, 
              :stop_following => :get, 
              :add_collaborator => :get,
              :create_collaborator => :post,
              :related_users => :get,
              :status_history => :get,
              :show_family_trees => :get,
              :new_clone => :get,
              :show_doc_version => :get }  do |projects|
      projects.resources :doc_versions  
      projects.resources :boms
      projects.resources :images
    end

  
  map.resources :boms do |boms|
    boms.resources :items, :member => { :show_doc_version => :get } do |items|
      items.resources :doc_versions
      items.resources :images
    end    
  end
  
  map.resources :proj_tags
  
  map.resources :bookmarklets

  map.resources :files
  
  map.resources :licenses
  map.dashboard '/dashboard', :controller => 'dashboard', :action => 'index'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup/:invitation_token', :controller => 'users', :action => 'new'
   map.events '/events', :controller =>'events', :action =>'index'
  map.resource :session

  map.root :controller => 'home', :action => 'index'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
