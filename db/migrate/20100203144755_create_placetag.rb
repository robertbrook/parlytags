class CreatePlacetag < ActiveRecord::Migration
  def self.up
    create_table :placetags do |t|
      t.string :name
      t.string :county
      t.string :country
      t.integer :place_id
      t.integer :geoname_id
    end
    
    create_table :placetags_tags, :id => false do |t|
      t.integer :placetag_id
      t.integer :tag_id
    end
  end

  def self.down
    drop_table :placetags
    drop_table :placetags_tags
  end
end
