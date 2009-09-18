set :application, "ditag"
set :repository,  "http://ditag.googlecode.com/svn/trunk/ditag"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/moddwebc/railsapps/#{application}"
set :scm_command, "/home/moddwebc/bin/svn"
set :local_scm_command, :default 
set :use_sudo, false
set :rails_env, :production
ssh_options[:keys] = %w(~/.ssh/id_rsa)

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
# set :scm, :subversion

role :app, "moddweb.com"
role :web, "moddweb.com"
role :db,  "moddweb.com", :primary => true
set :user, "moddwebc"

# =============================================================================
# TASKS
# =============================================================================

set :chmod755, %w(app config db lib public vendor script tmp public/dispatch.cgi public/dispatch.fcgi public/dispatch.rb)

desc "Set the proper permissions for directories and files on accounts and override environment.rb"
task :after_update_code, :roles => [:web] do
  run "rm #{release_path}/config/environment.rb && cp #{release_path}/config/environment_production.rb #{release_path}/config/environment.rb"
  run(chmod755.collect do |item|
    "chmod 755 #{release_path}/#{item}"
  end.join(" && "))
  %w{attachments}.each do |share|
    run "rm -rf #{release_path}/public/#{share}"
    run "mkdir -p #{shared_path}/system/#{share}"
    run "ln -nfs #{shared_path}/system/#{share} #{release_path}/public/#{share}"
  end
end

desc "Restart the FCGI Process"
task :restart, :roles => :app do
  run "cd #{current_path}; killall dispatch.fcgi"
  #cleanup
end