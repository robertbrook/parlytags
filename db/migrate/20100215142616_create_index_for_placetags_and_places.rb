class CreateIndexForPlacetagsAndPlaces < ActiveRecord::Migration
  def self.up
    add_index :places, :name
    add_index :places, :ascii_name
    add_index :places, :feature_code
    add_index :placetags, :name
  end

  def self.down
    remove_index :places, :name
    remove_index :places, :ascii_name
    remove_index :places, :feature_code
    remove_index :placetags, :name
  end
end
