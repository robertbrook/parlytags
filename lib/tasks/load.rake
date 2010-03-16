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
    
    if RAILS_ENV == "development"
      log << "cloning structure\n"
      Rake::Task["db:test:clone_structure"].invoke
    end
  end

  desc "Populate data for Places in DB"
  task :load_places => :environment do
    load_places
  end
  
  desc "Populate searchable data in DB"
  task :load_search_data => :environment do
    load_search_data
  end
  
  desc "Populate data for Constituencies in DB"
  task :load_constituencies => :environment do
    load_constituencies
  end

  desc "Populate data for EDM Items in DB"
  task :load_edms => :environment do
    load_edms
  end
  
  desc "Populate data for Written Answers in DB"
  task :load_wras => :environment do
    load_written_answers
  end
  
  desc "Populate data for Westminster Hall Debates in DB"
  task :load_westminster_hall => :environment do
    load_westminster_hall_debates
  end
  
  desc "Populate data for Hansard Debates in DB"
  task :load_debates => :environment do
    load_debates
  end
  
  desc "Populate data for WMS Items in DB"
  task :load_wms => :environment do
    load_wms
  end
  
  desc "Delete files in data directory"
  task :delete_data_files => :environment do
    delete_data_files
  end
end