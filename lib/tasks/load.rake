require File.expand_path(File.dirname(__FILE__) + '/../data_loader')

namespace :pt do
  include ParlyTags::DataLoader
  
  desc "Populate all the data for a demo"
  task :load_all_data => :environment do
    load_all_data
  end

  desc "Populate data for Places in DB"
  task :load_places => :environment do
    load_places
  end

  desc "Populate data for EDM Items in DB"
  task :load_edms => :environment do
    load_edms
  end
  
  desc "Populate data for Written Answers in DB"
  task :load_wras => :environment do
    load_written_answers
  end
  
  desc "Populate data for WMS Items in DB"
  task :load_wms => :environment do
    load_wms
  end
end