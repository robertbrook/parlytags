class LinkItemsToPlacetagsDropTags < ActiveRecord::Migration
  def self.up
    drop_table :placetags_tags
    drop_table :tags
    drop_table :items_tags
    
    create_table "items_placetags", :id => false do |t|
      t.integer "item_id"
      t.integer "placetag_id"
    end
  end

  def self.down
    create_table "items_tags", :id => false, :force => true do |t|
      t.integer "item_id"
      t.integer "tag_id"
    end
    
    create_table "placetags_tags", :id => false, :force => true do |t|
      t.integer "placetag_id"
      t.integer "tag_id"
    end
    
    create_table "tags", :force => true do |t|
      t.string "name"
    end
  end
end
