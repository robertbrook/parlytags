class AddTimestampsToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :created_at, :datetime
    add_column :items, :updated_at, :datetime
  end

  def self.down
    remove_column :items, :created_at
    remove_column :items, :updated_at
  end
end
