class SwitchToTagModel < ActiveRecord::Migration
  def self.up
    drop_table :tags
    drop_table :taggings
    
    create_table :tags do |t|
      t.string :name
    end
    
    create_table :items_tags, :id => false do |t|
      t.integer :item_id
      t.integer :tag_id
    end
  end

  def self.down
    drop_table :tags
    
    create_table :tags do |t|
      t.string :name, :default => ''
      t.string :kind, :default => '' 
    end

    create_table :taggings do |t|
      t.integer :tag_id

      t.string  :taggable_type, :default => ''
      t.integer :taggable_id
    end
    
    add_index :tags,     [:name, :kind]
    add_index :taggings, :tag_id
    add_index :taggings, [:taggable_id, :taggable_type]
  end
end