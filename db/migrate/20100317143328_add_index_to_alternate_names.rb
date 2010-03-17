class AddIndexToAlternateNames < ActiveRecord::Migration
  def self.up
    def self.up
      add_index :alternate_names, :name
    end
  end

  def self.down
    remove_index :alternate_names, :name
  end
end
