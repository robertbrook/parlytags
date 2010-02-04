require File.expand_path(File.dirname(__FILE__) + '/../data_loader')

# require 'htmlentities'

namespace :parlytags do
  include ParlyTags::DataLoader
  
  desc "Populate all the dummy data for a demo"
  task :load_dummy_data => :environment do
    load_dummy_data
  end

  desc "Populate data for Places in DB"
  task :load_places => :environment do
    load_places
  end

  desc "Populate data for Edms in DB"
  task :load_edms => :environment do
    load_edms
  end
  
  desc "Create items for each Edm"
  task :create_edm_items => :environment do
    create_edm_items
  end
end