# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100126104854) do

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

  create_table "known_places", :force => true do |t|
    t.string  "name"
    t.string  "geonameId"
    t.string  "yahooId"
    t.integer "lat",       :limit => 10, :precision => 10, :scale => 0
    t.integer "long",      :limit => 10, :precision => 10, :scale => 0
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

  create_table "places", :force => true do |t|
    t.integer "geoname_id"
    t.string  "name"
    t.string  "ascii_name"
    t.text    "alternate_names"
    t.float   "lat"
    t.float   "long"
    t.string  "feature_class"
    t.string  "feature_code"
    t.string  "country_code"
    t.string  "cc2"
    t.string  "admin1_code"
    t.string  "admin2_code"
    t.string  "admin3_code"
    t.string  "admin4_code"
    t.integer "population"
    t.integer "elevation"
    t.integer "gtopo30"
    t.string  "timezone"
    t.date    "last_modified"
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

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.string  "taggable_type", :default => ""
    t.integer "taggable_id"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name", :default => ""
    t.string "kind", :default => ""
  end

  add_index "tags", ["name", "kind"], :name => "index_tags_on_name_and_kind"

end
