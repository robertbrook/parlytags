require File.expand_path(File.dirname(__FILE__) + '/../data_loader')

namespace :parlytags do
  include ParlyTags::DataLoader
  
  desc "Reset database, load data, clone structure"
  task :reset_load_clone => :environment do
    log = Logger.new(STDOUT)
    
    log << "resetting database\n"
    Rake::Task["db:migrate:reset"].invoke
    
    log << "loading data\n"
    load_all_data
    
    log << "cloning structure\n"
    Rake::Task["db:test:clone_structure"].invoke
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