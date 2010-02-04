class CreateItems < ActiveRecord::Migration
  def self.up
    create_table :items do |t|
      t.string :title
      t.string :url
      t.text   :text #just for debugging, will be removed at a later date
      t.string :kind
    end
  end

  def self.down
    drop_table :items
  end
end
