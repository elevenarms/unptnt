require 'rubygems'
default_run_options[:pty] = true


set :application, "unptnt"
set :repository,  "http://unptnt.svn.beanstalkapp.com/dev/trunk"

set :deploy_to, "/home/deploy/#{application}"
set :use_sudo, false

role :app, "deploy@67.207.129.228"
role :web, "deploy@67.207.129.228"
role :db,  "deploy@67.207.129.228", :primary => true

task :after_update_code, :roles => :app do
	  run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
	  run "ln -nfs #{deploy_to}/#{shared_dir}/tmp/pids #{release_path}/tmp/pids"
    run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/item_images #{release_path}/public/item_images
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/user_images #{release_path}/public/user_images
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/project_images #{release_path}/public/project_images
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/file_attachments #{release_path}/public/file_attachments
	  EOF
	  run <<-EOF
	    cd #{release_path} && ln -s #{shared_path}/license_images #{release_path}/public/license_images
	  EOF

 	end