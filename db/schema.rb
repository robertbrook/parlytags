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

ActiveRecord::Schema.define(:version => 20100317143328) do

  create_table "alternate_names", :force => true do |t|
    t.string  "name"
    t.integer "place_id"
  end

  create_table "constituencies", :force => true do |t|
    t.string  "name"
    t.float   "lat"
    t.float   "lng"
    t.integer "area"
    t.float   "max_lat"
    t.float   "max_lng"
    t.float   "min_lat"
    t.float   "min_lng"
  end

  add_index "constituencies", ["name"], :name => "index_constituencies_on_name"

  create_table "constituencies_items", :id => false, :force => true do |t|
    t.integer "constituency_id"
    t.integer "item_id"
  end

  create_table "items", :force => true do |t|
    t.string   "title"
    t.string   "url"
    t.text     "text"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items_placetags", :id => false, :force => true do |t|
    t.integer "item_id"
    t.integer "placetag_id"
  end

  create_table "places", :force => true do |t|
    t.integer "geoname_id"
    t.string  "name"
    t.string  "ascii_name"
    t.text    "alternate_names"
    t.float   "lat"
    t.float   "lng"
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
    t.boolean "has_placetag"
  end

  add_index "places", ["ascii_name"], :name => "index_places_on_ascii_name"
  add_index "places", ["feature_code"], :name => "index_places_on_feature_code"
  add_index "places", ["name"], :name => "index_places_on_name"

  create_table "placetags", :force => true do |t|
    t.string  "name"
    t.string  "county"
    t.string  "country"
    t.integer "place_id"
    t.integer "geoname_id"
  end

  add_index "placetags", ["name"], :name => "index_placetags_on_name"

end
