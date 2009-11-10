class CreateProposers < ActiveRecord::Migration
  def self.up
    create_table :proposers do |t|
      t.integer :member_xml_id
      t.integer :edm_id
      t.string  :name
            
      t.timestamps
    end
  end

  def self.down
    drop_table :proposers
  end
end
