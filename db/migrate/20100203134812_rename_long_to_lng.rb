class RenameLongToLng < ActiveRecord::Migration
  def self.up
    rename_column :places, :long, :lng
  end

  def self.down
    rename_column :places, :lng, :long
  end
end
