load File.expand_path(File.dirname(__FILE__) + '/virtualserver/deploy_secrets.rb')

# Fill slice_url in - where you're installing your stack to
role :app, domain

# Fill user in - if remote user is different to your local user
set :user, root_user
set :password, root_password

set :repository, "git://github.com/robertbrook/parlytags.git"
set :scm, :git
set :deploy_via, :remote_cache

set :runner, deployuser

ssh_options[:forward_agent] = true

default_run_options[:pty] = true

set :application, 'parlytags'

namespace :deploy do
  set :user, deployuser
  set :password, deploypassword
  
  desc "Upload deployed database.yml"
  task :upload_deployed_database_yml, :roles => :app do
    data = File.read("config/virtualserver/deployed_database.yml")
    put data, "#{release_path}/config/database.yml", :mode => 0664
  end

  desc "Upload Google Maps API key"
  task :upload_google_maps_api_key, :roles => :app do
    data = File.read("config/virtualserver/deployed_gmaps_api_key.xml")
    put data, "#{release_path}/config/gmaps_api_key.yml", :mode => 0664
  end
  
  task :link_to_data, :roles => :app do
    data_dir = "#{deploy_to}/shared/cached-copy/data"
    run "if [ -d #{data_dir} ]; then ln -s #{data_dir} #{release_path}/data ; else echo cap deploy put_data first ; fi"
    
    log_dir = "#{deploy_to}/shared/log"
    run "if [ -d #{log_dir} ]; then echo #{log_dir} exists ; else mkdir #{log_dir} ; touch #{log_dir}/production.log ; chmod 0666 #{log_dir}/production.log; fi"

    run "if [ -d #{deploy_to}/shared/system ]; then echo exists ; else mkdir #{deploy_to}/shared/system ; fi"
    sudo "chmod a+rw #{release_path}/public/stylesheets"
  end
  
  task :run_migrations, :roles => :app do
    run "cd #{release_path}; rake db:create:all"
    run "cd #{release_path}; rake db:migrate RAILS_ENV=production"
    
    run "cd #{release_path}; rake parlytags:reset_load_clone RAILS_ENV=production"
    run "cd #{release_path}; rake parlytags:delete_data_files RAILS_ENV=production"
  end
  
  task :install_gems, :roles => :app do
    sudo "gem install json"
    sudo "gem install nokogiri"
    sudo "gem install geokit"
    sudo "gem install acts_as_tree"
    sudo "gem install htmlentities"
    sudo "gem install hpricot"
  end
  
  desc "Restarting apache and clearing the cache"
  task :restart, :roles => :app do
    sudo "/usr/sbin/apache2ctl restart"
  end
end

after 'deploy:setup', 'serverbuild:user_setup', 'serverbuild:setup_apache', 'deploy:install_gems'
after 'deploy:update_code', 'deploy:upload_deployed_database_yml', 'deploy:upload_google_maps_api_key', 'deploy:link_to_data'
after 'deploy:symlink', 'deploy:run_migrations'

def create_deploy_user
  create_user deployuser, deploygroup, deploypassword, true
end

def create_user username, group, newpassword, sudo=false
  begin
    sudo "grep '^#{group}:' /etc/group"
  rescue
    sudo "groupadd #{group}"
    sudo "echo \"%#{group} ALL=(ALL) ALL\" >> /etc/sudoers" if sudo
  end

  begin
    sudo "grep '^#{username}:' /etc/passwd"
  rescue
    sudo "useradd -g #{group} -s /bin/bash #{username}"
  end

  change_password username, newpassword

  run "if [ -d /home/#{username} ]; then echo exists ; else echo not found ; fi", :pty => true do |ch, stream, data|
    if data =~ /not found/
      sudo "mkdir /home/#{username}"
      sudo "chown #{username} /home/#{username}"
    end
  end
end

def change_password username, newpassword
  run "sudo passwd #{username}", :pty => true do |ch, stream, data|
    puts data
    if data =~ /Enter new UNIX password:/ or data =~ /Retype new UNIX password:/
      ch.send_data(newpassword + "\n")
    else
      Capistrano::Configuration.default_io_proc.call(ch, stream, data)
    end
  end
end

def put_data data_dir, file
  data_file = "#{data_dir}/#{file}"

  run "if [ -f #{data_file} ]; then echo exists ; else echo not there ; fi" do |channel, stream, message|
    if message.strip == 'not there'
      puts "sending #{file}"
      data = File.read("data/#{file.gsub('\\','')}")
      put data, "#{data_file}", :mode => 0664
    else
      puts "#{file} #{message}"
    end
  end
end