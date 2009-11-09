require File.expand_path(File.dirname(__FILE__) + '/../data_loader')

# require 'htmlentities'

namespace :parlytags do
  include ParlyTags::DataLoader

  desc "Populate data for Edms in DB"
  task :load_edms => :environment do
    load_edms
  end
end