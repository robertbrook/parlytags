class CreateConstituencies < ActiveRecord::Migration
  def self.up
    create_table :constituencies, :force => true do |t|
      t.string  :name
      t.float   :lat
      t.float   :lng
      t.integer :area
      t.float   :max_lat
      t.float   :max_lng
      t.float   :min_lat
      t.float   :min_lng
    end
    
    add_index :constituencies, :name
    
    create_table :constituencies_items, :id => false, :force => true do |t|
      t.integer :constituency_id
      t.integer :item_id
    end
  end

  def self.down
    remove_index :constituencies, :name
    drop_table :constituencies
    drop_table :constituencies_items
  end
end
