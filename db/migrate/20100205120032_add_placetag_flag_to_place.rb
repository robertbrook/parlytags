class AddPlacetagFlagToPlace < ActiveRecord::Migration
  def self.up
    add_column :places, :has_placetag, :boolean
  end

  def self.down
    remove_column :places, :has_placetag
  end
end
