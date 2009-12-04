class KnownPlaces < ActiveRecord::Migration
  def self.up
    create_table :known_places do |t|
      t.string :name
      t.string :geonameId
      t.string :yahooId
      t.decimal :lat
      t.decimal :long
    end
  end

  def self.down
    drop_table :known_places
  end
end
