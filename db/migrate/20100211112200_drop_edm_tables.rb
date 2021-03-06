class DropEdmTables < ActiveRecord::Migration
  def self.up
    drop_table :edms
    drop_table :members
    drop_table :motion_signatures
    drop_table :session_signatures
    drop_table :sessions
    drop_table :signatures
    drop_table :slugs
  end

  def self.down
    create_table "edms", :force => true do |t|
      t.integer  "motion_xml_id"
      t.string   "number"
      t.string   "title"
      t.text     "text"
      t.integer  "signature_count"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "session_id"
      t.integer  "parent_id"
      t.integer  "amendment_number"
    end
    
    create_table "members", :force => true do |t|
      t.string   "name"
      t.string   "member_xml_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "motion_signatures", :force => true do |t|
      t.integer "edm_id"
      t.integer "signature_id"
      t.string  "signature_type"
    end
    
    create_table "session_signatures", :force => true do |t|
      t.integer "session_id"
      t.integer "signature_id"
      t.integer "signature_type"
    end
    
    create_table "sessions", :force => true do |t|
      t.string "name"
    end
    
    create_table "signatures", :force => true do |t|
      t.integer "member_id"
      t.string  "type"
      t.integer "edm_id"
      t.integer "session_id"
      t.date    "date"
    end
    
    create_table "slugs", :force => true do |t|
      t.string   "name"
      t.integer  "sluggable_id"
      t.integer  "sequence",                     :default => 1, :null => false
      t.string   "sluggable_type", :limit => 40
      t.string   "scope",          :limit => 40
      t.datetime "created_at"
    end

    add_index "slugs", ["name", "sluggable_type", "scope", "sequence"], :name => "index_slugs_on_n_s_s_and_s", :unique => true
    add_index "slugs", ["sluggable_id"], :name => "index_slugs_on_sluggable_id"
  end
end
