class DropProposers < ActiveRecord::Migration
  def self.up
    drop_table :proposers
  end

  def self.down
    create_table :proposers do |t|
      t.integer :member_xml_id
      t.integer :edm_id
      t.string  :name
            
      t.timestamps
    end
  end
end
