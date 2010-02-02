class RemoveKnownPlaces < ActiveRecord::Migration
  def self.up
    drop_table :known_places
  end

  def self.down
    create_table :known_places do |t|
      t.string :name
      t.string :geonameId
      t.string :yahooId
      t.decimal :lat
      t.decimal :long
    end
  end
end
