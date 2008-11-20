

  desc "create initial admin users"
  task :create_initial_users => :environment do
    admin1 = User.create(
      :login => "dave", 
      :name => "Dave Rauchwerk", 
      :email => "dave@unptnt.com", 
      :password => "password", 
      :password_confirmation => "password"
      )
    admin1.activated_at = 5.days.ago
    admin1.activation_code = nil
    admin1.save false
    
    admin2 = User.create(
      :login => "brownell", 
      :name => "Brownell Chalstrom", 
      :email => "unptnt@chalstrom.com", 
      :password => "password", 
      :password_confirmation => "password"
      )
    admin2.activated_at = 5.days.ago
    admin2.activation_code = nil
    admin2.save false
  end 



